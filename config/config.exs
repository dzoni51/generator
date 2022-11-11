# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :generator,
  ecto_repos: [Generator.Repo]

# Configures the endpoint
config :generator, GeneratorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GeneratorWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Generator.PubSub,
  live_view: [signing_salt: "sVtBFFXh"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :generator, Generator.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

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

config :generator, Oban,
  repo: Generator.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [subscriptions: 10]

config :ex_ngrok,
  # The name of the Ngrok executable
  executable: "ngrok",
  # The type of tunnel (http, https, tcp, or tls)
  protocol: "https",
  # The port to which Ngrok will forward requests
  port: "4000",
  # The URL of Ngrok's API (used to retrieve its settings)
  api_url: "http://localhost:4040/api/tunnels",
  # The amount of sleep (in ms) to put between attempts to connect to Ngrok
  sleep_between_attempts: 200,
  # Any other tunneling options that will be passed directly to Ngrok
  options: ""

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
