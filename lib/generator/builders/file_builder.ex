defmodule Generator.Builders.FileBuilder do
  @moduledoc """
  A module used for building files.
  """

  @type module_string() :: String.t()

  @spec config_prod_file(module_string(), String.t()) :: String.t()
  def config_prod_file(module, domain) do
    GeneratorWeb.FileView.render("config_prod.text",
      module: module,
      camelized_module_name: camelize(module),
      domain: domain
    )
  end

  @spec config_file(module_string()) :: String.t()
  def config_file(module) do
    GeneratorWeb.FileView.render("config.text",
      module: module,
      camelized_module_name: camelize(module)
    )
  end

  @spec endpoint_file(module_string()) :: String.t()
  def endpoint_file(module) do
    GeneratorWeb.FileView.render("endpoint.text",
      module: module,
      camelized_module_name: camelize(module)
    )
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
    GeneratorWeb.FileView.render("controller.text",
      functions: functions,
      camelized_module_name: camelize(module)
    )
  end

  # TODO: Do we need {:phoenix_live_view, "~> 0.17.5"} in the deps?
  @spec mix_file(module_string()) :: String.t()
  def mix_file(module) do
    GeneratorWeb.FileView.render("mix.text",
      module: module,
      camelized_module_name: camelize(module)
    )
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
    GeneratorWeb.FileView.render("cache.text",
      module: module
    )
  end

  @spec counter_plug_file() :: String.t()
  def counter_plug_file() do
    GeneratorWeb.FileView.render("counter_plug.text")
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
    GeneratorWeb.FileView.render("application.text",
      camelized_module_name: camelize(module)
    )
  end

  @spec router_file(module_string(), String.t()) :: String.t()
  def router_file(module, routes) do
    GeneratorWeb.FileView.render("router.text",
      camelized_module_name: camelize(module),
      routes: routes
    )
  end

  defp camelize(module), do: Phoenix.Naming.camelize(module)
end
