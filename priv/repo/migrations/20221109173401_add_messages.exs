defmodule Generator.Repo.Migrations.AddMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :body, :text
      add :sent_by, :string
      add :thread_id, references(:threads, type: :uuid)

      timestamps(updated_at: false)
    end
  end
end
