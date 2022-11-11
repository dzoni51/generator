# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Generator.Repo.insert!(%Generator.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Generator.Repo
alias Generator.Accounts.User
alias Generator.Messages.Message
alias Generator.Threads.Thread
alias Generator.Plans.Plan
alias Generator.Plans

Repo.delete_all(Plan)

%{
  "name" => "Personal",
  "price_monthly" => Decimal.new("19.90"),
  "price_yearly" => Decimal.new("209.90"),
  "braintree_id" => "kt2g"
}
|> Plans.create_plan()

%{
  "name" => "CMS",
  "price_monthly" => Decimal.new("49.90"),
  "price_yearly" => Decimal.new("579.90"),
  "braintree_id" => "kt2g"
}
|> Plans.create_plan()

%{
  "name" => "Bussiness",
  "price_monthly" => Decimal.new("34.90"),
  "price_yearly" => Decimal.new("399.90"),
  "braintree_id" => "kt2g"
}
|> Plans.create_plan()

Repo.delete_all(Message)
Repo.delete_all(Thread)
Repo.delete_all(User)

{:ok, user_1} =
  Generator.Accounts.register_user(%{"email" => "test1@test.com", "password" => "password123"})

{:ok, user_2} =
  Generator.Accounts.register_user(%{"email" => "test2@test.com", "password" => "password123"})

{:ok, user_3} =
  Generator.Accounts.register_user(%{"email" => "test3@test.com", "password" => "password123"})

{:ok, thread_1} = Generator.Threads.create_thread(%{"name" => "thread1", "user_id" => user_1.id})
{:ok, thread_2} = Generator.Threads.create_thread(%{"name" => "thread2", "user_id" => user_2.id})
{:ok, thread_3} = Generator.Threads.create_thread(%{"name" => "thread3", "user_id" => user_3.id})

Generator.Messages.create_message(%{
  "sent_by" => "test1@test.com",
  "body" => "message_body",
  "thread_id" => thread_1.id
})

Generator.Messages.create_message(%{
  "sent_by" => "test2@test.com",
  "body" => "message_body",
  "thread_id" => thread_2.id
})

Generator.Messages.create_message(%{
  "sent_by" => "test3@test.com",
  "body" => "message_body",
  "thread_id" => thread_3.id
})

%Braintree.CreditCard{
  card_type: "test type",
  last_4: "1234",
  expiration_year: "2024",
  expiration_month: "02",
  default: true,
  created_at: to_string(DateTime.utc_now()),
  token: "test_token"
}
|> Generator.Cards.create_card(user_1.id)

%{
  "kind" => "SubscriptionChargedSuccessfully",
  "timestamp" => to_string(DateTime.utc_now()),
  "subscription_id" => "test_id",
  "amount" => "19.90",
  "user_id" => user_1.id,
  "charged_with_payment_method_token" => "test_token"
}
|> Generator.Transactions.create_transaction()

%{
  "kind" => "SubscriptionCanceled",
  "timestamp" => to_string(DateTime.utc_now()),
  "subscription_id" => "test_id",
  "amount" => "19.90",
  "user_id" => user_1.id,
  "charged_with_payment_method_token" => "test_token"
}
|> Generator.Transactions.create_transaction()

%{
  "kind" => "SubscriptionChargedUnsuccessfully",
  "timestamp" => to_string(DateTime.utc_now()),
  "subscription_id" => "test_id",
  "amount" => "19.90",
  "user_id" => user_1.id,
  "charged_with_payment_method_token" => "test_token"
}
|> Generator.Transactions.create_transaction()
