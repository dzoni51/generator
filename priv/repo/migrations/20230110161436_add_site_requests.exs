defmodule Generator.Repo.Migrations.AddSiteRequests do
  use Ecto.Migration

  def change do
    create table(:site_requests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :status, :string
      # add :type, :string, null: false should user know the type?
      add :description, :text, null: false
      # add :ssl_fields?
      # add :domain_name?
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      timestamps()
    end
  end
end
