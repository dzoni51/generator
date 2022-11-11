defmodule Generator.Repo.Migrations.AddPlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :name, :string
      add :price_monthly, :decimal
      add :price_yearly, :decimal
      add :braintree_id, :string
    end
  end
end
