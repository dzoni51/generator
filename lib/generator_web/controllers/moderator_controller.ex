defmodule GeneratorWeb.ModeratorController do
  use GeneratorWeb, :controller

  alias Generator.Accounts.Moderator
  alias Generator.Accounts
  alias Generator.Sites

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

  def show(conn, %{"id" => id}) do
    with %Moderator{} = mod <- Accounts.get_user_moderator(id, conn.assigns.current_user.id) do
      render(conn, "show.html",
        moderator: mod,
        sites: Sites.list_user_sites_id_and_name(conn.assigns.current_user.id),
        site_permissions: Utils.split(mod.site_permissions, "\n", [])
      )
    else
      _ ->
        conn
        |> put_flash(:error, "That page does not exist.")
        |> redirect(to: Routes.moderator_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "permissions" => permissions}) do
    with %Moderator{} = mod <- Accounts.get_user_moderator(id, conn.assigns.current_user.id) do
      case Accounts.set_moderator_permissions(mod, permissions) do
        {:ok, mod} ->
          conn
          |> put_flash(:info, "Permissions updated successfully.")
          |> redirect(to: Routes.moderator_path(conn, :show, mod))

        {:error, _cs} ->
          conn
          |> put_flash(:error, "Oops, an error occured, please try again.")
          |> redirect(to: Routes.moderator_path(conn, :show, mod))
      end
    else
      _ ->
        conn
        |> put_flash(:error, "That page does not exist.")
        |> redirect(to: Routes.moderator_path(conn, :index))
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
