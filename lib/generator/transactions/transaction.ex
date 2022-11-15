defmodule Generator.Transactions.Transaction do
  use Generator.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :timestamp, :string
    field :subscription_id, :string
    field :kind, :string
    field :amount, :string
    field :charged_with_payment_method_token, :string

    belongs_to :user, Generator.Accounts.User
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :timestamp,
      :subscription_id,
      :kind,
      :amount,
      :user_id,
      :charged_with_payment_method_token
    ])
    |> validate_required([:user_id, :charged_with_payment_method_token])
  end
end
