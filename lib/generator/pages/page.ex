defmodule Generator.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :name, :string
    field :code, :string
    field :route, :string

    belongs_to :site, Generator.Sites.Site
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :code, :route, :site_id])
    |> validate_required([:name, :code, :route])
  end
end
