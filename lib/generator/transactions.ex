defmodule Generator.Transactions do
  @moduledoc """
  The transactions context.
  """

  import Ecto.Query, warn: false
  alias Generator.Repo
  alias Generator.Transactions.Transaction
  alias Generator.Accounts.User
  alias Generator.Accounts

  def list_user_transactions(user_id) do
    with %User{} = user <- Accounts.get_user!(user_id) do
      user
      |> Ecto.assoc(:transactions)
      |> Repo.all()
    end
  end

  def create_transaction(attrs) do
    attrs
    |> Transaction.new()
    |> Repo.insert()
  end
end
