defmodule Generator.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :timestamp, :string
    field :subscription_id, :string
    field :kind, :string
    field :balance, :string

    belongs_to :user, Generator.Accounts.User
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:timestamp, :subscription_id, :kind, :balance, :user_id])
    |> validate_required([:user_id])
  end
end
