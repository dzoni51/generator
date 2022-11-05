defmodule ProbaWeb.PageController do
  use ProbaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
