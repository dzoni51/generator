defmodule GeneratorWeb.SiteLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Sites
  alias Generator.Sites.Site
  alias Generator.Accounts

  @impl true
  def mount(%{"user_id" => user_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:user, Accounts.get_user!(user_id))
     |> assign(:sites, list_user_sites(user_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("build", %{"id" => site_id}, socket) do
    Sites.build_site(site_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("deploy", %{"id" => site_id}, socket) do
    Sites.deploy(site_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_build", %{"id" => site_id}, socket) do
    Sites.delete_site_build(site_id)

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Site")
    |> assign(:site, Sites.get_site!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Site")
    |> assign(:site, %Site{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sites")
    |> assign(:site, nil)
  end

  defp list_user_sites(user_id) do
    Sites.list_user_sites(user_id)
  end
end
