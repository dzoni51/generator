defmodule Generator.Components.Component do
  use Ecto.Schema
  import Ecto.Changeset

  schema "components" do
    field :code, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(component, attrs) do
    component
    |> cast(attrs, [:name, :code])
    |> validate_required([:name, :code])
  end
end
