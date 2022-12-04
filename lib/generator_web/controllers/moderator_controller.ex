defmodule GeneratorWeb.ModeratorController do
  use GeneratorWeb, :controller

  alias Generator.Accounts.Moderator
  alias Generator.Accounts

  def index(conn, _params) do
    render(conn, "index.html",
      moderators: Accounts.get_user_moderators(conn.assigns.current_user.id)
    )
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Accounts.change_moderator_registration(%Moderator{}))
  end

  def create(conn, %{"moderator" => mod_params}) do
    case Accounts.register_moderator(Map.put(mod_params, "user_id", conn.assigns.current_user.id)) do
      {:ok, _mod} ->
        conn
        |> put_flash(:info, "Moderator created successfully.")
        |> redirect(to: Routes.moderator_path(conn, :index))

      {:error, cs} ->
        render(conn, "new.html", changeset: cs)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Moderator{} = mod <- Accounts.get_moderator!(id) do
      case Accounts.delete_moderator(mod) do
        {:ok, _mod} ->
          conn
          |> put_flash(:info, "Moderator deleted successfully.")
          |> redirect(to: Routes.moderator_path(conn, :index))

        {:error, _cs} ->
          conn
          |> put_flash(:error, "Moderator could not be deleted.")
          |> redirect(to: Routes.moderator_path(conn, :index))
      end
    end
  end
end
