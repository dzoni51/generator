defmodule GeneratorWeb.BillingController do
  use GeneratorWeb, :controller

  alias Generator.Accounts.User

  def index(conn, _params) do
    {:ok, token} = Braintree.ClientToken.generate()
    render(conn, "index.html", token: token)
  end

  def checkout(conn, %{
        "payment_method_nonce" => payment_method_nonce,
        "device_data" => device_data,
        "save_card" => save_card
      }) do
    %{
      amount: "10.00",
      payment_method_nonce: payment_method_nonce,
      device_data: device_data,
      options: %{submit_for_settlement: true}
    }
    |> Braintree.Transaction.sale()
    |> case do
      {:ok, _} ->
        #maybe_create_braintree_customer(conn.assigns.current_user)
        #maybe_save_card(conn.assigns.current_user, payment_method_nonce, save_card)

        conn
        |> put_flash(:info, "Payment successful")
        |> redirect(to: Routes.billing_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(
          :error,
          "Oops, something went wrong. Please check errors below and try again."
        )
        |> redirect(to: Routes.billing_path(conn, :index))
    end
  end
end
