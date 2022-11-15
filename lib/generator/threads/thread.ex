defmodule Generator.Threads.Thread do
  use Generator.Schema

  import Ecto.Changeset

  schema "threads" do
    field :name, :string
    field :archived, :boolean, default: false
    field :needs_reply, :boolean, default: true

    timestamps()

    belongs_to :user, Generator.Accounts.User
    has_many :messages, Generator.Messages.Message
  end

  def new(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:name, :archived, :user_id, :needs_reply])
    |> validate_required([:name, :archived, :user_id, :needs_reply])
  end
end
