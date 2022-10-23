defmodule GeneratorWeb.DashboardController do
  use GeneratorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
