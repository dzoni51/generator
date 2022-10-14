defmodule Generator.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  alias Generator.Repo

  alias Generator.Sites.Site

  def list_sites do
    Repo.all(Site)
  end

  def get_site!(id), do: Repo.get!(Site, id) |> Repo.preload(:pages)

  def create_site(attrs) do
    %Site{}
    |> Site.changeset(attrs)
    |> Repo.insert()
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def build_site(site_id) do
    with %Site{} = site <- get_site!(site_id) do
      app_path = Path.join(priv_path(), site.module)

      mix_phx_new(app_path)
    end
  end

  def delete_site_build(site_id) do
    with %Site{} = site <- get_site!(site_id) do
      app_path = Path.join(priv_path(), site.module)
      File.rm_rf(app_path)
    end
  end

  defp priv_path do
    :code.priv_dir(:generator)
  end

  defp mix_phx_new(app_path) do
    System.cmd("mix", [
      "phx.new",
      app_path,
      "--no-ecto",
      "--no-gettext",
      "--no-dashboard",
      "--no-live",
      "--no-mailer",
      "--no-install"
    ])
  end
end
