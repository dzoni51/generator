defmodule Generator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Generator.Repo,
      # Start the Telemetry supervisor
      GeneratorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Generator.PubSub},
      # Start the Endpoint (http/https)
      GeneratorWeb.Endpoint,
      # Start a worker by calling: Generator.Worker.start_link(arg)
      # {Generator.Worker, arg}
      {Oban, Application.fetch_env!(:generator, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Generator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GeneratorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
