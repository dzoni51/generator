defmodule Generator.Messages.Message do
  use Ecto.Schema

  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :sent_by, :string

    timestamps(updated_at: false)

    belongs_to :thread, Generator.Threads.Thread
  end

  def new(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :sent_by, :thread_id])
    |> validate_required([:body, :sent_by, :thread_id])
  end
end
