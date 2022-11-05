defmodule GeneratorWeb.SiteLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Sites
  alias Generator.Sites.Site

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :sites, list_sites())}
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

  defp list_sites() do
    Sites.list_sites()
  end
end
