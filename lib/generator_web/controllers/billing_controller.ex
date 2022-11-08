defmodule GeneratorWeb.BillingController do
  use GeneratorWeb, :controller

  require Logger

  alias Generator.Accounts.User
  alias Generator.Accounts

  def index(conn, _params) do
    case conn.assigns.current_user do
      %User{braintree_id: nil} ->
        render(conn, "index.html", credit_cards: [])

      %User{braintree_id: braintree_id} ->
        with {:ok, %Braintree.Customer{credit_cards: credit_cards}} <-
               Braintree.Customer.find(braintree_id) do
          render(conn, "index.html", credit_cards: credit_cards)
        else
          _ ->
            render(conn, "index.html", credit_cards: :error)
        end
    end
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
    with {:ok, %User{braintree_id: b_id}} <-
           maybe_create_braintree_customer(conn.assigns.current_user) do
      %{customer_id: b_id, payment_method_nonce: payment_method_nonce}
      |> Braintree.PaymentMethod.create()
      |> case do
        {:ok, _} ->
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
