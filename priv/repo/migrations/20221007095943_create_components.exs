defmodule Generator.Repo.Migrations.CreateComponents do
  use Ecto.Migration

  def change do
    create table(:components) do
      add :name, :string
      add :code, :text

      timestamps()
    end
  end
end
