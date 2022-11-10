defmodule Generator.Repo.Migrations.AddPages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :name, :string
      add :code, :text
      add :route, :string
      add :module, :string
      add :site_id, references(:sites)
    end
  end
end
