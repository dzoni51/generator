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

      remove_default_stuff(app_path, site)

      {routes, controller_content} =
        Enum.reduce(site.pages, {"", ""}, fn page, acc ->
          {routes, controller_content} = acc

          route = """
          get "#{page.route}", PageController, :#{page.module}
          """

          function = """
          def #{page.name}(conn, _params) do
            render(conn, "#{page.name}.html")
          end\n
          """

          template_path =
            templates_path(app_path, site.module)
            |> Path.join("page/#{page.module}.html.heex")

          File.write(template_path, page.code)

          {route <> routes, function <> controller_content}
        end)

      router_path(app_path, site.module)
      |> update_router(String.trim(routes))

      controller_path(app_path, site.module)
      |> build_controller(String.trim(controller_content), site.module)

      # * Write mixfile with deps
      File.write(mixfile_path(app_path), build_mix_file(site))

      # * Write configs
      #write_configs(site)
    end
  end

  #TODO:
  # defp write_configs(site) do
  #   write_config(site)
  #   write_dev(site)
  # end

  defp mixfile_path(app_path), do: Path.join(app_path, "mix.exs")

  defp remove_default_stuff(app_path, site) do
    # * Remove default css
    File.rm(Path.join(css_folder_path(app_path), "phoenix.css"))
    File.write(Path.join(css_folder_path(app_path), "app.css"), "")
    # * Remove Topbar
    File.rm(topbar_path(app_path))
    # * Write default root layout
    File.write(root_layout_path(app_path, site.module), default_root_layout_html(site.name))
    # * Remove default page index template
    File.rm(default_page_index_path(app_path, site.module))
  end

  defp default_page_index_path(app_path, module),
    do: Path.join(app_path, "lib/#{module}_web/templates/page/index.html.heex")

  defp root_layout_path(app_path, module),
    do: Path.join(app_path, "lib/#{module}_web/templates/layout/root.html.heex")

  defp default_root_layout_html(site_name) do
    """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="csrf-token" content={csrf_token_value()}>
        <%= live_title_tag assigns[:page_title] || "#{site_name}" %>
        <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn, "/assets/app.css")}/>
        <script defer phx-track-static type="text/javascript" src={Routes.static_path(@conn, "/assets/app.js")}></script>
      </head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  defp css_folder_path(app_path), do: Path.join(app_path, "assets/css")

  defp topbar_path(app_path), do: Path.join(app_path, "assets/vendor/topbar.js")

  defp build_controller(controller_path, content, module) do
    camelized_module_name = Phoenix.Naming.camelize(module)

    controller_content = """
    defmodule #{camelized_module_name}Web.PageController do
      use #{camelized_module_name}Web, :controller

      #{content}
    end
    """

    File.write(controller_path, controller_content)
  end

  defp router_path(app_path, module) do
    Path.join(app_path, "lib/#{module}_web/router.ex")
  end

  defp templates_path(app_path, module) do
    Path.join(app_path, "lib/#{module}_web/templates")
  end

  defp controller_path(app_path, module) do
    Path.join(app_path, "lib/#{module}_web/controllers/page_controller.ex")
  end

  def delete_site_build(site_id) do
    with %Site{} = site <- get_site!(site_id) do
      app_path = Path.join(priv_path(), site.module)
      File.rm_rf(app_path)
    end
  end

  # ! This does not exist in PROD ENV
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

  defp default_router_route do
    """
    get "/", PageController, :index
    """
  end

  defp update_router(router_path, routes) do
    {:ok, router} = File.read(router_path)

    router_content = String.replace(router, default_router_route(), routes)

    File.write(router_path, router_content)
  end

  defp default_deps() do
    [
      """
      {:phoenix, "~> 1.6.13"}
      """,
      """
      {:phoenix_html, "~> 3.0"}
      """,
      """
      {:phoenix_live_view, "~> 0.17.5"}
      """,
      """
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev}
      """,
      """
      {:telemetry_metrics, "~> 0.6"}
      """,
      """
      {:telemetry_poller, "~> 1.0"}
      """,
      """
      {:jason, "~> 1.2"}
      """,
      """
      {:plug_cowboy, "~> 2.5"}
      """,
      """
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev}
      """
    ]
  end

  defp build_mix_file(%Site{module: module}) do
    camelized_module_name = Phoenix.Naming.camelize(module)

    """
    defmodule #{camelized_module_name}.MixProject do
      use Mix.Project

      def project do
        [
          app: :#{module},
          version: "0.1.0",
          elixir: "~> 1.12",
          elixirc_paths: elixirc_paths(Mix.env()),
          compilers: [] ++ Mix.compilers(),
          start_permanent: Mix.env() == :prod,
          aliases: aliases(),
          deps: deps()
        ]
      end

      def application do
        [
          mod: {#{camelized_module_name}.Application, []},
          extra_applications: [:logger, :runtime_tools]
        ]
      end

      defp elixirc_paths(:test), do: ["lib", "test/support"]
      defp elixirc_paths(_), do: ["lib"]

      defp deps do
        #{default_deps()}
      end

      defp aliases do
        [
          setup: ["deps.get", "ecto.setup"],
          "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
          "ecto.reset": ["ecto.drop", "ecto.setup"],
          test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
          "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
        ]
      end
    end
    """
  end
end
