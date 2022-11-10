defmodule Generator.Repo.Migrations.AddMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :sent_by, :string
      add :thread_id, references(:threads)

      timestamps(updated_at: false)
    end
  end
end
