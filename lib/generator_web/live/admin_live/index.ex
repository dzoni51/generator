defmodule GeneratorWeb.AdminLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Admins
  alias Generator.Admins.Admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :admins, list_admins())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Admins.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Admins")
    |> assign(:admin, nil)
  end

  defp list_admins() do
    Admins.list_admins()
  end
end
