defmodule Generator.Repo.Migrations.AddSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :module, :string
      add :css, :text
      add :domain, :string
      add :region, :string
      add :user_id, references(:users)
    end
  end
end
