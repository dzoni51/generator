defmodule Generator.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :timestamp, :string
      add :subscription_id, :string
      add :kind, :string
      add :amount, :string
      add :charged_with_payment_method_token, :string
      add :user_id, references(:users, type: :uuid)
    end
  end
end
