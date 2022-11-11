defmodule Generator.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plans" do
    field :name, :string
    field :price_monthly, :decimal
    field :price_yearly, :decimal
    field :braintree_id
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:name, :price_monthly, :price_yearly, :braintree_id])
    |> validate_required([:name, :price_monthly, :price_yearly, :braintree_id])
  end
end
