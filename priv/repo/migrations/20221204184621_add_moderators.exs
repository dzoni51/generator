defmodule Generator.Repo.Migrations.AddModerators do
  use Ecto.Migration

  def change do
    create table(:moderators, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :site_permissions, :string
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      timestamps()
    end
  end
end
