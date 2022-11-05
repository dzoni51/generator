defmodule Proba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ProbaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Proba.PubSub},
      # Start the Endpoint (http/https)
      ProbaWeb.Endpoint
      # Start a worker by calling: Proba.Worker.start_link(arg)
      # {Proba.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProbaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
