defmodule Generator.Sites.Site do
  use Generator.Schema

  import Ecto.Changeset

  @default_illegal_characters [
    " ",
    ".",
    ",",
    "!",
    "~",
    "@",
    "#",
    "$",
    "%",
    "^",
    "&",
    "*",
    "(",
    ")",
    "+",
    "=",
    "[",
    "]",
    "-"
  ]

  schema "sites" do
    field :name, :string
    field :css, :string
    field :module, :string
    field :domain, :string
    field :region, :string
    field :deployed_at, :utc_datetime

    has_many :pages, Generator.Pages.Page
    belongs_to :user, Generator.Accounts.User
  end

  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :css, :domain, :region, :user_id])
    |> validate_required([:name, :domain, :region, :user_id])
    |> maybe_update_module()
  end

  def deploy(site) do
    change(site, deployed_at: DateTime.truncate(DateTime.utc_now(), :second))
  end

  defp maybe_update_module(cs) do
    with {:ok, name} <- fetch_change(cs, :name) do
      change =
        name
        |> remove_illegal_characters()
        |> Phoenix.Naming.underscore()
        |> String.trim()

      cs
      |> put_change(:module, change)
    else
      _ ->
        cs
    end
  end

  defp remove_illegal_characters(string, characters \\ @default_illegal_characters) do
    Enum.reduce(characters, string, fn character, acc ->
      acc
      |> String.replace(character, "")
    end)
  end
end
