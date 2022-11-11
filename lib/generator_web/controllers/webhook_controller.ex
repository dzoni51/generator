defmodule GeneratorWeb.WebhookController do
  use GeneratorWeb, :controller

  alias Generator.Transactions
  alias Generator.Accounts
  alias Generator.Accounts.User

  require Logger

  # def create(conn, %{"bt_signature" => bt_signature, "bt_payload" => bt_payload}) do
  #   case Braintree.Webhook.parse(bt_signature, bt_payload) do
  #     {:ok, %{"payload" => payload, "signature" => _sig}} ->
  #       IO.inspect(payload)
  #       save_webhook_notification(payload)

  #       conn
  #       |> put_status(200)
  #       |> json(%{})

  #     error ->
  #       Logger.error("Bad webhook, #{inspect(error, pretty: true)}")
  #       conn
  #       |> put_status(200)
  #       |> json(%{})

  #   end
  # end

  def create(conn, params) do
    IO.inspect(conn)
    IO.inspect(params)

    conn
    |> put_status(200)
    |> json(%{})
  end

  # defp save_webhook_notification(%{
  #        "kind" => kind,
  #        "timestamp" => timestamp,
  #        "subscription" => sub_map
  #      }) do
  #   with %Braintree.Subscription{} = subscription <- Braintree.Subscription.new(sub_map),
  #        %User{id: user_id} <- Accounts.get_user_by_subscription_id(subscription.id) do
  #     %{
  #       "kind" => kind,
  #       "timestamp" => timestamp,
  #       "balance" => subscription.balance,
  #       "subscription_id" => subscription.id,
  #       "user_id" => user_id
  #     }
  #     |> Transactions.create_transaction()
  #   end
  # end
end
