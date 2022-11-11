defmodule Generator.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :timestamp, :string
      add :subscription_id, :string
      add :kind, :string
      add :balance, :string
      add :user_id, references(:users)
    end
  end
end
