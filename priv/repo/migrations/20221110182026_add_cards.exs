defmodule Generator.Repo.Migrations.AddCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :card_type, :string
      add :last_4, :string
      add :expiration_year, :string
      add :expiration_month, :string
      add :default, :boolean
      add :added_on, :string
      add :token, :string
      add :user_id, references(:users)
    end
  end
end
