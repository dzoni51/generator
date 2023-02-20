defmodule Generator.Sites.Request do
  use Generator.Schema

  import Ecto.Changeset

  schema "site_requests" do
    field :description, :string
    field :status, :string

    belongs_to :user, Generator.Accounts.User
    timestamps()
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:description, :status, :user_id])
    |> validate_required([:description, :user_id])
  end
end
