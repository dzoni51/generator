defmodule Generator.Builders.Reporter do
  alias Generator.Sites.Site

  def write(site, app_path) do
    counter_path(site.module, app_path)
    |> File.mkdir()

    counter_web_path(site.module, app_path)
    |> File.mkdir()

    write_cache(site, app_path)
    write_counter_plug(site, app_path)
    write_reporter(site, app_path)
    write_scheduler(site, app_path)
    # add_children_to_application_tree()
    # add_plug_to_router()
  end

  def write_scheduler(%Site{module: module_name}, app_path) do
    value =
      """
      defmodule Scheduler do
        use Quantum, otp_app: :#{module_name}
      end
      """

    File.write(scheduler_file_name(module_name, app_path), value)
  end
  def write_reporter(%Site{id: site_id, module: module_name}, app_path) do
    value = """
    defmodule Reporter do
      def report_visits() do
        with {:ok, %HTTPoison.Response{status_code: 200}} <-
               HTTPoison.post(
                 "https://5da3-2a06-5b03-a0ff-fa00-00-3.ngrok.io/webhooks/report-visits",
                 Jason.encode!(%{site_id: "#{site_id}", visits: Cache.get(:visits)}),
                 [{"Content-Type", "application/json"}]
               ) do
          Cache.put(:visits, 0)
        end
      end
    end
    """

    File.write(reporter_file_path(module_name, app_path), value)
  end

  def write_cache(%Site{module: module}, app_path) do
    value = """
    defmodule Cache do
      use Nebulex.Cache,
        otp_app: :#{module},
        adapter: Nebulex.Adapters.Local
    end
    """

    File.write(cache_file_path(module, app_path), value)
  end

  def write_counter_plug(%Site{module: module_name}, app_path) do
    value = """
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

    File.write(counter_plug_path(module_name, app_path), value)
  end

  defp scheduler_file_name(module_name, app_path) do
    module_name
    |> counter_path(app_path)
    |> Path.join("scheduler.ex")
  end

  defp reporter_file_path(module_name, app_path) do
    module_name
    |> counter_path(app_path)
    |> Path.join("reporter.ex")
  end

  defp counter_path(module_name, app_path) do
    Path.join(app_path, "lib/#{module_name}/counter")
  end

  defp counter_web_path(module_name, app_path) do
    Path.join(app_path, "lib/#{module_name}_web/counter")
  end

  defp cache_file_path(module_name, app_path) do
    module_name
    |> counter_web_path(app_path)
    |> Path.join("cache.ex")
  end

  defp counter_plug_path(module_name, app_path) do
    module_name
    |> counter_web_path(app_path)
    |> Path.join("counter_plug.ex")
  end
end
