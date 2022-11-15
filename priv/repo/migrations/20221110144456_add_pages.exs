defmodule Generator.Repo.Migrations.AddPages do
  use Ecto.Migration

  def change do
    create table(:pages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :code, :text
      add :route, :string
      add :module, :string
      add :site_id, references(:sites, type: :uuid)
    end
  end
end
