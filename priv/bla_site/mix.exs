defmodule BlaSite.MixProject do
  use Mix.Project

  def project do
    [
      app: :bla_site,
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
      mod: {BlaSite.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    {:phoenix, "~> 1.6.13"}
{:phoenix_html, "~> 3.0"}
{:phoenix_live_view, "~> 0.17.5"}
{:esbuild, "~> 0.4", runtime: Mix.env() == :dev}
{:telemetry_metrics, "~> 0.6"}
{:telemetry_poller, "~> 1.0"}
{:jason, "~> 1.2"}
{:plug_cowboy, "~> 2.5"}
{:tailwind, "~> 0.1", runtime: Mix.env() == :dev}

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
