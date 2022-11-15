defmodule Generator.Admins.Admin do
  use Generator.Schema

  import Ecto.Changeset

  schema "admins" do
    field :first_name, :string
    field :last_name, :string
  end

  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
