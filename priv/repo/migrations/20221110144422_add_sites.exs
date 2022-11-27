defmodule Generator.Repo.Migrations.AddSites do
  use Ecto.Migration

  def change do
    create table(:sites, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :module, :string
      add :css, :text
      add :domain, :string
      add :region, :string
      add :deployed_at, :utc_datetime
      add :user_id, references(:users, type: :uuid)
    end
  end
end
