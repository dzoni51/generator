defmodule GeneratorWeb.BillingController do
  use GeneratorWeb, :controller

  def index(conn, _params) do
    {:ok, token} = Braintree.ClientToken.generate()
    render(conn, "index.html", token: token)
  end

  def checkout(conn, params) do
    IO.inspect(params)
    {:ok, token} = Braintree.ClientToken.generate()

    render(conn, "index.html", token: token)
  end
end
