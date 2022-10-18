defmodule BlaSiteWeb.PageController do
  use BlaSiteWeb, :controller

  def wow(conn, _params) do
  render(conn, "wow.html")
end

def proba(conn, _params) do
  render(conn, "proba.html")
end
end
