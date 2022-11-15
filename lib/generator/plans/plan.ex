defmodule Generator.Plans.Plan do
  use Generator.Schema

  import Ecto.Changeset

  schema "plans" do
    field :name, :string
    field :type, Ecto.Enum, values: [:monthly, :yearly]
    field :price, :decimal
    field :braintree_id
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :price, :type, :braintree_id])
    |> validate_required([:name, :price, :type, :braintree_id])
  end
end
