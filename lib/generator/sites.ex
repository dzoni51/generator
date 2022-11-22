defmodule Generator.Sites do
  @moduledoc """
  The Sites context.
  """

  import Ecto.Query, warn: false
  alias Generator.Repo
  alias Generator.Sites.Site
  alias Generator.Paths
  alias Generator.FileBuilder
  alias Generator.Pages.Page

  def list_sites do
    Repo.all(Site)
  end

  def list_user_sites(user_id) do
    user_id
    |> Generator.Accounts.get_user!()
    |> Ecto.assoc(:sites)
    |> Repo.all()
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

  def update_visits(%Site{} = site, new_visits) do
    site
    |> Site.update_visits(%{"visits" => new_visits})
    |> Repo.update()
  end

  def build_site(site_id) do
    with %Site{module: module, pages: pages} = site <- get_site!(site_id) do
      app_path = Paths.application_path(module)

      mix_phx_new(app_path)

      remove_default_stuff(site)

      {routes, controller_content} =
        Enum.reduce(pages, {"", ""}, fn %Page{
                                          route: route,
                                          module: page_module,
                                          name: page_name,
                                          code: page_code
                                        },
                                        {routes, controller_content} ->
          module
          |> Paths.page_template_path(page_module)
          |> File.write(page_code)

          {FileBuilder.build_route(route, page_module) <> routes,
           FileBuilder.build_controller_function(page_name) <> controller_content}
        end)

      module
      |> update_router(String.trim(routes))

      module
      |> build_controller(String.trim(controller_content))

      # * Write mixfile with deps
      Paths.mixfile_path(module)
      |> File.write(FileBuilder.mix_file(module))

      # * Write configs
      write_configs(site)
    end
  end

  defp write_configs(site) do
    write_config_file(site)
    write_prod_file(site)
  end

  defp write_prod_file(%Site{module: module, domain: domain}) do
    Paths.prod_path(module)
    |> File.write(FileBuilder.config_prod_file(module, domain))
  end

  defp write_config_file(%Site{module: module}) do
    Paths.config_path(module)
    |> File.write(FileBuilder.config_file(module))
  end

  # defp runtime_path(app_path), do: Path.join(app_path, "config/runtime.exs")

  defp remove_default_stuff(%Site{module: module, name: site_name} = site) do
    # * Remove default css
    module
    |> Paths.phoenix_css_file()
    |> File.rm()

    module
    |> Paths.app_css_file()
    |> File.write("")

    # * Remove Topbar
    module
    |> Paths.topbar_path()
    |> File.rm()

    # * Write default root layout
    module
    |> Paths.root_layout_path()
    |> File.write(FileBuilder.root_layout_html_file(site_name))

    # * Remove default page index template
    module
    |> Paths.template_page_index_path()
    |> File.rm()

    # * Remove code reloader from endpoint.ex
    clean_endpoint(site)
  end

  defp clean_endpoint(%Site{module: module}) do
    module
    |> Paths.endpoint_path()
    |> File.write(FileBuilder.endpoint_file(module))
  end

  defp build_controller(module, functions) do
    module
    |> Paths.controller_path()
    |> File.write(FileBuilder.controller_file(module, functions))
  end

  def delete_site_build(site_id) do
    with %Site{module: module} <- get_site!(site_id) do
      module
      |> Paths.application_path()
      |> File.rm_rf()
    end
  end

  defp mix_phx_new(app_path) do
    System.cmd("mix", [
      "phx.new",
      app_path,
      "--no-gettext",
      "--no-dashboard",
      "--no-live",
      "--no-mailer",
      "--no-install"
    ])
  end

  defp default_router_route do
    """
    get "/", PageController, :index
    """
  end

  defp update_router(module, routes) do
    router_path =
      module
      |> Paths.router_path()

    {:ok, router} =
      router_path
      |> File.read()

    router_content = String.replace(router, default_router_route(), routes)

    File.write(router_path, router_content)
  end

  def deploy(site_id) do
    with %Site{module: module} = site <- get_site!(site_id) do
      update_site_deploy_timestamp(site)

      System.cmd(
        "fly",
        [
          ~s(launch),
          ~s(--dockerignore-from-gitignore),
          ~s(--name "#{site.name}"),
          ~s(--region "#{site.region}"),
          ~s(--org "personal"),
          ~s(--now),
          ~s(--copy-config)
        ],
        cd: Paths.application_path(module)
      )
    end
  end

  def update_site_deploy_timestamp(site) do
    site
    |> Site.deploy()
    |> Repo.update()
  end
end
