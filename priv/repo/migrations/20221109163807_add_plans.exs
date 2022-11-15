defmodule Generator.Repo.Migrations.AddPlans do
  use Ecto.Migration

  def change do
    create table(:plans, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :type, :string
      add :price, :decimal
      add :braintree_id, :string
    end
  end
end
