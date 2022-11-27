defmodule Generator.Builders.FileBuilder do
  @moduledoc """
  A module used for building files.
  """

  @type module_string() :: String.t()

  @spec config_prod_file(module_string(), String.t()) :: String.t()
  def config_prod_file(module, domain) do
    camelized_module_name = camelize(module)

    """
    import Config


    config :#{module}, #{camelized_module_name}Web.Endpoint,
     cache_static_manifest: "priv/static/cache_manifest.json",
     url: [host: "#{domain}"]

    config :logger, level: :info
    """
  end

  @spec config_file(module_string()) :: String.t()
  def config_file(module) do
    camelized_module_name = camelize(module)

    """
    import Config

    # Configures the endpoint
    config :#{module}, #{camelized_module_name}Web.Endpoint,
    url: [host: "localhost"],
    render_errors: [view: #{camelized_module_name}Web.ErrorView, accepts: ~w(html json), layout: false],
    pubsub_server: #{camelized_module_name}.PubSub,
    live_view: [signing_salt: "#{Utils.generate_random_salt()}"]

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
  end

  @spec endpoint_file(module_string()) :: String.t()
  def endpoint_file(module) do
    camelized_module_name = camelize(module)

    """
    defmodule #{camelized_module_name}Web.Endpoint do
      use Phoenix.Endpoint, otp_app: :#{module}

      # The session will be stored in the cookie and signed,
      # this means its contents can be read but not tampered with.
      # Set :encryption_salt if you would also like to encrypt it.
      @session_options [
        store: :cookie,
        key: "_#{module}_key",
        signing_salt: "#{Utils.generate_random_salt()}"
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
  end

  @spec root_layout_html_file(String.t()) :: String.t()
  def root_layout_html_file(site_name) do
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

  @spec controller_file(module_string(), String.t()) :: String.t()
  def controller_file(module, functions) do
    camelized_module_name = camelize(module)

    """
    defmodule #{camelized_module_name}Web.PageController do
      use #{camelized_module_name}Web, :controller

      #{functions}
    end
    """
  end

  # TODO: Do we need {:phoenix_live_view, "~> 0.17.5"} in the deps?
  @spec mix_file(module_string()) :: String.t()
  def mix_file(module) do
    camelized_module_name = camelize(module)

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
        [
          {:phoenix, "~> 1.6.13"},
          {:phoenix_html, "~> 3.0"},
          {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
          {:telemetry_metrics, "~> 0.6"},
          {:telemetry_poller, "~> 1.0"},
          {:jason, "~> 1.2"},
          {:plug_cowboy, "~> 2.5"},
          {:tailwind, "~> 0.1", runtime: Mix.env() == :dev} ,
          {:nebulex, "~> 2.4"},
          {:httpoison, "~> 1.8"}
        ]
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

  @spec build_route(String.t(), module_string()) :: String.t()
  def build_route(route, module) do
    """
    get "#{route}", PageController, :#{module}
    """
  end

  @spec build_controller_function(String.t()) :: String.t()
  def build_controller_function(page_name) do
    """
    def #{page_name}(conn, _params) do
      render(conn, "#{page_name}.html")
    end\n
    """
  end

  # * Reporter
  @spec cache_file(module_string()) :: String.t()
  def cache_file(module) do
    """
    defmodule Cache do
      use Nebulex.Cache,
        otp_app: :#{module},
        adapter: Nebulex.Adapters.Local
    end
    """
  end

  @spec counter_plug_file() :: String.t()
  def counter_plug_file() do
    """
    defmodule CounterPlug do
      import Plug.Conn

      def init(opts), do: opts

      def call(conn, _opts) do
        case get_session(conn, :uuid) do
          nil ->
            log_visit()

            conn
            |> put_unique_user_id()

          _uuid ->
            conn
        end
      end

      defp put_unique_user_id(conn) do
        token = :crypto.strong_rand_bytes(32)

        conn
        |> put_session(:uuid, token)
      end

      defp log_visit() do
        Cache.incr(:visits, 1)
      end
    end
    """
  end

  # @spec reporter_file(Ecto.UUID.t()) :: String.t()
  # def reporter_file(site_id) do
  #   """
  #   defmodule Reporter do
  #     def report_visits() do
  #       Process.sleep(Enum.random(1..120000))
  #       with {:ok, %HTTPoison.Response{status_code: 200}} <-
  #              HTTPoison.post(
  #                "https://5da3-2a06-5b03-a0ff-fa00-00-3.ngrok.io/webhooks/report-visits",
  #                Jason.encode!(%{site_id: "#{site_id}", visits: Cache.get(:visits)}),
  #                [{"Content-Type", "application/json"}]
  #              ) do
  #         Cache.put(:visits, 0)
  #       end
  #     end
  #   end
  #   """
  # end

  # @spec scheduler_file(module_string()) :: String.t()
  # def scheduler_file(module) do
  #   """
  #   defmodule Scheduler do
  #     use Quantum, otp_app: :#{module}
  #   end
  #   """
  # end

  @spec application_file(module_string()) :: String.t()
  def application_file(module) do
    camelized_module_name = camelize(module)

    """
    defmodule #{camelized_module_name}.Application do

      use Application

      @impl true
      def start(_type, _args) do
        children = [
          # Start the Ecto repository
          #{camelized_module_name}.Repo,
          # Start the Telemetry supervisor
          #{camelized_module_name}Web.Telemetry,
          # Start the PubSub system
          {Phoenix.PubSub, name: #{camelized_module_name}.PubSub},
          # Start the Endpoint (http/https)
          #{camelized_module_name}Web.Endpoint,
          {Cache, []}
        ]

        opts = [strategy: :one_for_one, name: #{camelized_module_name}.Supervisor]
        Supervisor.start_link(children, opts)
      end

      # Tell Phoenix to update the endpoint configuration
      # whenever the application is updated.
      @impl true
      def config_change(changed, _new, removed) do
        #{camelized_module_name}Web.Endpoint.config_change(changed, removed)
        :ok
      end
    end
    """
  end

  @spec router_file(module_string(), String.t()) :: String.t()
  def router_file(module, routes) do
    camelized_module_name = camelize(module)

    """
    defmodule #{camelized_module_name}Web.Router do
      use #{camelized_module_name}Web, :router

      pipeline :browser do
        plug :accepts, ["html"]
        plug :fetch_session
        plug :fetch_live_flash
        plug :put_root_layout, {#{camelized_module_name}Web.LayoutView, :root}
        plug :protect_from_forgery
        plug :put_secure_browser_headers
        plug CounterPlug
      end

      pipeline :api do
        plug :accepts, ["json"]
      end

      scope "/", TestWeb do
        pipe_through :browser

        #{routes}
      end
    end
    """
  end

  defp camelize(module), do: Phoenix.Naming.camelize(module)
end
