defmodule Generator.Messages do
  @moduledoc """
  The messages context.
  """

  import Ecto.Query, warn: false
  alias Generator.Messages.Message
  alias Generator.Repo

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def get_last_message_by_from(from) do
    Message
    |> where(from: ^from)
    |> last(:inserted_at)
    |> Repo.one()
  end

  def support_email_address(), do: "test@company.com"
end
