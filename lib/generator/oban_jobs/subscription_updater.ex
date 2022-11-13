# defmodule Generator.ObanJobs.SubscriptionUpdater do
#   use Oban.Worker,
#     queue: :subscriptions,
#     unique: [period: 30],
#     max_attempts: 1

#   alias Generator.Accounts
#   alias Generator.Accounts.User
#   alias Generator.Plans.Plan

#   require Logger

#   @impl Oban.Worker
#   def perform(_) do
#     Accounts.list_users_that_started_plan_in_last_month()
#     |> Enum.map(&update_user_subscription_price(&1))

#     Logger.info("Successfully finished updating subscriptions")

#     :ok
#   end

#   defp update_user_subscription_price(%User{subscription_id: nil, id: id}) do
#     Logger.error("Subscription_id doesn't exist for user_id: #{id}")
#     {:error, :subscription_does_not_exist}
#   end

#   defp update_user_subscription_price(%User{plan: nil, id: id}) do
#     Logger.error("User not on plan when trying to update subscription, user_id: #{id}")
#     {:error, :user_not_on_plan}
#   end

#   defp update_user_subscription_price(%User{
#          subscription_id: sub_id,
#          plan: %Plan{price: price}
#        }) do
#     Braintree.Subscription.update(sub_id, %{"price" => price})
#   end
# end
