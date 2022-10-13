defmodule Generator.Sites.Site do
  use Ecto.Schema

  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :css, :string

    has_many :pages, Generator.Pages.Page
  end

  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name, :css])
    |> validate_required([:name])
  end
end
