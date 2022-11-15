defmodule Generator.Repo.Migrations.AddThreads do
  use Ecto.Migration

  def change do
    create table(:threads, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :user_id, references(:users, type: :uuid)
      add :archived, :boolean
      add :needs_reply, :boolean

      timestamps()
    end
  end
end
