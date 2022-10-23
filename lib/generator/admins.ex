defmodule Generator.Admins do
  @moduledoc """
  The admins context.
  """

  import Ecto.Query, warn: false
  alias Generator.Repo

  alias Generator.Admins.Admin

  def list_admins do
    Repo.all(Admin)
  end

  def get_admin!(id), do: Repo.get!(Admin, id)

  def create_admin(attrs) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end
end
