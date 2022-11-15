defmodule Generator.Repo.Migrations.AddUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :braintree_id, :string
      add :confirmed_at, :naive_datetime
      add :plan_id, references(:plans, type: :uuid)
      add :subscription_id, :string
      add :plan_started_on, :date
      add :custom_plan_price, :string
      add :next_billing_date, :string
      add :next_billing_period_amount, :string
      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
