defmodule Generator.Pages.Page do
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

  schema "pages" do
    field :name, :string
    field :code, :string
    field :route, :string
    field :module, :string

    belongs_to :site, Generator.Sites.Site
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :code, :route, :site_id])
    |> validate_required([:name, :code, :route])
    |> maybe_update_module()
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
