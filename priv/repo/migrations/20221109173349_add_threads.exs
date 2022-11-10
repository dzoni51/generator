defmodule Generator.Repo.Migrations.AddThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :name, :string
      add :user_id, references(:users)
      add :archived, :boolean
      add :needs_reply, :boolean

      timestamps()
    end
  end
end
