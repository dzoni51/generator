defmodule GeneratorWeb.PageLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Sites
  alias Generator.Pages
  alias Generator.Pages.Page

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    {:ok, assign(socket, :site, Sites.get_site!(site_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, Pages.get_page!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, %Page{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:page, nil)
  end
end
