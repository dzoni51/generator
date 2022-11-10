defmodule GeneratorWeb.BillingController do
  use GeneratorWeb, :controller

  require Logger

  alias Generator.Cards
  alias Generator.Cards.Card
  alias Generator.Accounts
  alias Generator.Accounts.User

  def index(conn, _params) do
    render(conn, "index.html", credit_cards: Cards.list_user_cards(conn.assigns.current_user.id))
  end

  def new(conn, _params) do
    {:ok, token} = Braintree.ClientToken.generate()

    render(conn, "new.html", token: token)
  end

  def create(conn, %{
        "payment_method_nonce" => payment_method_nonce
        # "device_data" => device_data,
        # "save_card" => save_card
      }) do
    with {:ok, %User{braintree_id: b_id, id: user_id}} <-
           maybe_create_braintree_customer(conn.assigns.current_user) do
      %{customer_id: b_id, payment_method_nonce: payment_method_nonce}
      |> Braintree.PaymentMethod.create()
      |> case do
        {:ok, payment_method} ->
          Cards.create_card(payment_method, user_id)

          conn
          |> put_flash(:info, "Card added successfully!")
          |> redirect(to: Routes.billing_path(conn, :index))

        {:error, _} ->
          conn
          |> put_flash(:error, "Oops, something went wrong. Please try again.")
          |> redirect(to: Routes.billing_path(conn, :index))
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Card{token: token} = card <- Cards.get_card!(id),
         {:ok, _card} <- Cards.delete_card(card),
         :ok <- Braintree.PaymentMethod.delete(token) do
      conn
      |> put_flash(:info, "Card deleted successfully.")
      |> redirect(to: Routes.billing_path(conn, :index))
    else
      {:error, :card_is_default} ->
        conn
        |> put_flash(
          :error,
          "You can't delete default card. Please set another card to default before deleting this one."
        )
        |> redirect(to: Routes.billing_path(conn, :index))

      {:error, %Braintree.ErrorResponse{} = _error_response} ->
        conn
        |> put_flash(
          :error,
          "Something went wrong. Please contact customer support with error code: 1"
        )
        |> redirect(to: Routes.billing_path(conn, :index))

      _ ->
        conn
        |> put_flash(
          :error,
          "Something went wrong. Please contact customer support with error code: 2"
        )
        |> redirect(to: Routes.billing_path(conn, :index))
    end
  end

  def make_default(conn, %{"id" => id}) do
    with %Card{token: token} = card <- Cards.get_card!(id) do
      case Braintree.Customer.update(conn.assigns.current_user.braintree_id, %{
             default_payment_method_token: token
           }) do
        {:ok, _} ->
          Cards.set_default(card, conn.assigns.current_user.id)

          conn
          |> put_flash(:info, "Card updated successfully.")
          |> redirect(to: Routes.billing_path(conn, :index))

        _ ->
          conn
          |> put_flash(
            :error,
            "Something went wrong when trying to update your card. Please try again."
          )
          |> redirect(to: Routes.billing_path(conn, :index))
      end
    end
  end

  defp maybe_create_braintree_customer(%User{braintree_id: nil, email: email} = user) do
    %{email: email}
    |> Braintree.Customer.create()
    |> case do
      {:ok, %Braintree.Customer{id: braintree_id}} ->
        user
        |> Accounts.update_user_braintree_id(braintree_id)

      {:error, error} ->
        Logger.error("Could not create braintree customer. #{inspect(error, pretty: true)}")
        error
    end
  end

  defp maybe_create_braintree_customer(user), do: {:ok, user}
end
