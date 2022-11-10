defmodule Generator.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :card_type, :string
    field :last_4, :string
    field :expiration_year, :string
    field :expiration_month, :string
    field :default, :boolean, default: false
    field :added_on, :string
    field :token, :string

    belongs_to :user, Generator.Accounts.User
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  @cast_fields [
    :card_type,
    :last_4,
    :expiration_year,
    :expiration_month,
    :default,
    :added_on,
    :token,
    :user_id
  ]
  @required_fields [
    :card_type,
    :last_4,
    :expiration_year,
    :expiration_month,
    :default,
    :added_on,
    :user_id
  ]

  def changeset(card, attrs) do
    card
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  def set_default_value(card, value) do
    change(card, default: value)
  end
end
