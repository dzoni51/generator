defmodule GeneratorWeb.WebhookController do
  use GeneratorWeb, :controller

  alias Generator.Transactions
  alias Generator.Accounts
  alias Generator.Accounts.User

  require Logger

  def create(conn, %{"bt_signature" => bt_signature, "bt_payload" => bt_payload}) do
    case Braintree.Webhook.parse(bt_signature, bt_payload) do
      {:ok, %{"payload" => xml_payload, "signature" => _sig}} ->
        xml_payload
        |> Braintree.XML.Decoder.load()
        |> save_webhook_notification()

        conn
        |> put_status(200)
        |> json(%{})

      error ->
        Logger.error("Bad webhook, #{inspect(error, pretty: true)}")

        conn
        |> put_status(200)
        |> json(%{})
    end
  end

  defp save_webhook_notification(%{
         "notification" => %{
           "kind" => kind,
           "timestamp" => timestamp,
           "subscription" => sub_map
         }
       }) do
    with %Braintree.Subscription{} = subscription <- Braintree.Subscription.new(sub_map),
         %User{id: user_id} <- Accounts.get_user_by_subscription_id(subscription.id) do
      %{
        "kind" => kind,
        "timestamp" => timestamp,
        "amount" => get_transaction_amount(subscription.transactions),
        "subscription_id" => subscription.id,
        "user_id" => user_id
      }
      |> Transactions.create_transaction()
    end
  end

  defp save_webhook_notification(notification) do
    Logger.warning("Notification not supported, #{inspect(notification, pretty: true)}")
    {:error, :notification_not_supported}
  end

  defp get_transaction_amount(transactions) do
    [latest_transaction | _tail] = transactions
    latest_transaction.amount
  end
end
