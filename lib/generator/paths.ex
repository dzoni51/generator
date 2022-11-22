defmodule Generator.Paths do
  @moduledoc """
  The paths context.
  """

  @spec application_path(String.t()) :: String.t()
  def application_path(module) do
    priv_path()
    |> Path.join(module)
  end

  # TODO: This does not exist in PROD ENV ?? Is this true?
  def priv_path do
    :code.priv_dir(:generator)
  end

  @spec router_path(String.t()) :: String.t()
  def router_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/router.ex")
  end

  @spec controller_path(String.t()) :: String.t()
  def controller_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/controllers/page_controller.ex")
  end

  @spec mixfile_path(String.t()) :: String.t()
  def mixfile_path(module) do
    module
    |> application_path()
    |> Path.join("mix.exs")
  end

  @spec prod_path(String.t()) :: String.t()
  def prod_path(module) do
    module
    |> application_path()
    |> Path.join("config/prod.exs")
  end

  @spec config_path(String.t()) :: String.t()
  def config_path(module) do
    module
    |> application_path()
    |> Path.join("config/config.exs")
  end

  @spec css_folder_path(String.t()) :: String.t()
  def css_folder_path(module) do
    module
    |> application_path()
    |> Path.join("assets/css")
  end

  @spec phoenix_css_file(String.t()) :: String.t()
  def phoenix_css_file(module) do
    module
    |> css_folder_path()
    |> Path.join("phoenix.css")
  end

  @spec app_css_file(String.t()) :: String.t()
  def app_css_file(module) do
    module
    |> css_folder_path()
    |> Path.join("app.css")
  end

  @spec topbar_path(String.t()) :: String.t()
  def topbar_path(module) do
    module
    |> application_path()
    |> Path.join("assets/vendor/topbar.js")
  end

  @spec root_layout_path(String.t()) :: String.t()
  def root_layout_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/templates/layout/root.html.heex")
  end

  @spec template_page_index_path(String.t()) :: String.t()
  def template_page_index_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/templates/page/index.html.heex")
  end

  @spec endpoint_path(String.t()) :: String.t()
  def endpoint_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/endpoint.ex")
  end

  @spec page_template_path(String.t(), String.t()) :: String.t()
  def page_template_path(application_module, page_module) do
    application_module
    |> application_path()
    |> Path.join("page/#{page_module}.html.heex")
  end

  # * Reporter paths

  @spec counter_folder_path(String.t()) :: String.t()
  def counter_folder_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}/counter")
  end

  @spec counter_web_folder_path(String.t()) :: String.t()
  def counter_web_folder_path(module) do
    module
    |> application_path()
    |> Path.join("lib/#{module}_web/counter")
  end

  @spec scheduler_file_path(String.t()) :: String.t()
  def scheduler_file_path(module) do
    module
    |> counter_folder_path()
    |> Path.join("scheduler.ex")
  end

  @spec reporter_file_path(String.t()) :: String.t()
  def reporter_file_path(module) do
    module
    |> counter_folder_path()
    |> Path.join("reporter.ex")
  end

  @spec cache_file_path(String.t()) :: String.t()
  def cache_file_path(module) do
    module
    |> counter_web_folder_path()
    |> Path.join("cache.ex")
  end

  @spec counter_plug_file_path(String.t()) :: String.t()
  def counter_plug_file_path(module) do
    module
    |> counter_web_folder_path()
    |> Path.join("counter_plug.ex")
  end
end
