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
      write_configs(app_path, site)
    end
  end

  defp write_configs(app_path, site) do
    write_config_file(app_path, site)
    write_prod_file(app_path, site)
  end

  defp write_prod_file(app_path, %Site{module: module, domain: domain}) do
    camelized_module_name = Phoenix.Naming.camelize(module)

    config_content = """
    import Config


    config :#{module}, #{camelized_module_name}Web.Endpoint,
     cache_static_manifest: "priv/static/cache_manifest.json",
     url: [host: "#{domain}"]

    config :logger, level: :info
    """

    File.write(prod_path(app_path), config_content)
  end

  defp write_config_file(app_path, %Site{module: module}) do
    camelized_module_name = Phoenix.Naming.camelize(module)

    config_content = """
    import Config

    # Configures the endpoint
    config :#{module}, #{camelized_module_name}Web.Endpoint,
    url: [host: "localhost"],
    render_errors: [view: #{camelized_module_name}Web.ErrorView, accepts: ~w(html json), layout: false],
    pubsub_server: #{camelized_module_name}.PubSub,
    live_view: [signing_salt: "#{generate_random_salt()}"]

    # Configure esbuild (the version is required)
    config :esbuild,
    version: "0.14.29",
    default: [
      args:
        ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    ]

    # Configures Elixir's Logger
    config :logger, :console,
    format: "$time $metadata[$level] $message\n",
    metadata: [:request_id]

    # Use Jason for JSON parsing in Phoenix
    config :phoenix, :json_library, Jason

    # * Tailwind config
    config :tailwind,
    version: "3.1.8",
    default: [
      args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
      cd: Path.expand("../assets", __DIR__)
    ]

    # Import environment specific config. This must remain at the bottom
    # of this file so it overrides the configuration defined above.
    import_config "\#{config_env()}.exs"
    """

    File.write(config_path(app_path), config_content)
  end

  defp config_path(app_path), do: Path.join(app_path, "config/config.exs")

  defp prod_path(app_path), do: Path.join(app_path, "config/prod.exs")

  # defp runtime_path(app_path), do: Path.join(app_path, "config/runtime.exs")

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
    # * Remove code reloader from endpoint.ex
    clean_endpoint(app_path, site)
  end

  defp clean_endpoint(app_path, %Site{module: module}) do
    path = endpoint_path(app_path, module)

    with true <- File.exists?(path) do
      camelized_module_name = Phoenix.Naming.camelize(module)

      new_endpoint_content = """
      defmodule #{camelized_module_name}Web.Endpoint do
        use Phoenix.Endpoint, otp_app: :#{module}

        # The session will be stored in the cookie and signed,
        # this means its contents can be read but not tampered with.
        # Set :encryption_salt if you would also like to encrypt it.
        @session_options [
          store: :cookie,
          key: "_#{module}_key",
          signing_salt: "#{generate_random_salt()}"
        ]


        # Serve at "/" the static files from "priv/static" directory.
        #
        # You should set gzip to true if you are running phx.digest
        # when deploying your static files in production.
        plug Plug.Static,
          at: "/",
          from: :#{module},
          gzip: false,
          only: ~w(assets fonts images)

        plug Plug.RequestId
        plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

        plug Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Phoenix.json_library()

        plug Plug.MethodOverride
        plug Plug.Head
        plug Plug.Session, @session_options
        plug #{camelized_module_name}Web.Router
      end
      """

      File.write(path, new_endpoint_content)
    else
      _ ->
        {:error, :file_not_found}
    end
  end

  @alphabet_lower_case [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  ]
  defp generate_random_salt() do
    alphabet_upper_case =
      Enum.into(@alphabet_lower_case, [], fn letter -> String.upcase(letter) end)

    numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    Enum.reduce(1..8, "", fn _, acc ->
      case Enum.random([1, 2, 3]) do
        1 ->
          acc <> Enum.random(@alphabet_lower_case)

        2 ->
          acc <> Enum.random(alphabet_upper_case)

        3 ->
          acc <> to_string(Enum.random(numbers))
      end
    end)
  end

  defp endpoint_path(app_path, module), do: Path.join(app_path, "lib/#{module}_web/endpoint.ex")

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
        #{write_deps(default_deps())}
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

  defp write_deps(deps) do
    Enum.reduce(deps, "[\n", fn dep, acc ->
      acc <> trim(dep) <> "," <> "\n"
    end) <> "]"
  end

  defp trim(to_trim) do
    to_trim
    |> String.replace("\n", "")
    |> String.trim()
  end

  def deploy(site_id) do
    with %Site{} = site <- get_site!(site_id) do
      app_path = Path.join(priv_path(), site.module)

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
        cd: app_path
      )
    end
  end
end
