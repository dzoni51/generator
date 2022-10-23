defmodule Generator.Repo.Migrations.AddAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :first_name, :string
      add :last_name, :string
    end
  end
end
