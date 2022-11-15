defmodule GeneratorWeb.VisitReportController do
  use GeneratorWeb, :controller

  alias Generator.Sites
  alias Generator.Sites.Site

  def create(conn, %{"site_id" => nil, "visits" => _}) do
    send_ok_response(conn)
  end

  def create(conn, %{"site_id" => site_id, "visits" => nil}) do
    with %Site{} = site <- Sites.get_site!(site_id) do
      Sites.update_visits(site, 0)

      send_ok_response(conn)
    end
  end

  def create(conn, %{"site_id" => site_id, "visits" => visits}) do
    with %Site{} = site <- Sites.get_site!(site_id) do
      Sites.update_visits(site, visits)

      send_ok_response(conn)
    end
  end

  defp send_ok_response(conn) do
    conn
    |> put_status(200)
    |> json(%{})
  end
end
