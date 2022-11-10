defmodule Generator.Cards do
  @moduledoc """
  The cards context.
  """

  import Ecto.Query, warn: false
  alias Generator.Repo
  alias Generator.Accounts
  alias Generator.Cards.Card
  alias Braintree.CreditCard

  def list_user_cards(user_id) do
    user_id
    |> Accounts.get_user!()
    |> Ecto.assoc(:cards)
    |> Repo.all()
  end

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(
        %CreditCard{
          card_type: card_type,
          last_4: last_4,
          expiration_year: expiration_year,
          expiration_month: expiration_month,
          default: default,
          created_at: added_on,
          token: token
        },
        user_id
      ) do
    %{
      "card_type" => card_type,
      "last_4" => last_4,
      "expiration_year" => expiration_year,
      "expiration_month" => expiration_month,
      "default" => default,
      "added_on" => added_on,
      "token" => token,
      "user_id" => user_id
    }
    |> Card.new()
    |> Repo.insert()
    |> case do
      {:ok, %Card{default: true} = card} ->
        set_default(card, user_id)

      value ->
        value
    end
  end

  def delete_card(%Card{default: false} = card) do
    Repo.delete(card)
  end

  def delete_card(_), do: {:error, :card_is_default}

  def set_default(%Card{default: true, id: id} = card, user_id) do
    query = from c in Card, where: c.user_id == ^user_id and c.id != ^id

    Repo.all(query)
    |> Enum.map(&set_card_default_value(&1, false))

    {:ok, card}
  end

  def set_default(%Card{default: false, id: id} = card, user_id) do
    query = from c in Card, where: c.user_id == ^user_id and c.id != ^id

    Repo.all(query)
    |> Enum.map(&set_card_default_value(&1, false))

    card
    |> set_card_default_value(true)
  end

  def get_user_default_payment_token(user_id) do
    query = from c in Card, where: c.user_id == ^user_id and c.default, select: c.token

    Repo.one(query)
  end

  defp set_card_default_value(%Card{} = card, value) do
    card
    |> Card.set_default_value(value)
    |> Repo.update()
  end

  defp set_card_default_value(_, _), do: {:error, :card_does_not_exist}
end
