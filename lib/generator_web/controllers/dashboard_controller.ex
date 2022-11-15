defmodule GeneratorWeb.DashboardController do
  use GeneratorWeb, :controller

  alias Generator.Sites

  def index(conn, _params) do
    render(conn, "index.html", sites: Sites.list_user_sites(conn.assigns.current_user.id))
  end
end
