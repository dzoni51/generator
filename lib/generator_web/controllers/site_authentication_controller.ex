defmodule GeneratorWeb.SiteAuthenticationController do
  use GeneratorWeb, :controller

  alias Generator.Accounts
  alias Generator.Accounts.User
  alias Generator.Accounts.Moderator

  def create(conn, %{"email" => email, "password" => password, "site_id" => site_id}) do
    case Accounts.auth_user_or_moderator_for_site(email, password, site_id) do
      %User{} = _user ->
        # update last login
        auth_ok_response(conn)

      %Moderator{} = _moderator ->
        # update last login
        auth_ok_response(conn)

      _ ->
        auth_error_response(conn)
    end
  end

  defp auth_ok_response(conn) do
    conn
    |> put_status(200)
    |> json(%{authenticated: true})
  end

  defp auth_error_response(conn) do
    conn
    |> put_status(200)
    |> json(%{authenticated: false})
  end
end
