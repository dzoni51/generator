defmodule Generator.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :module, :string
      add :css, :text
      add :domain, :string
    end
  end
end
