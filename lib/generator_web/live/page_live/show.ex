defmodule GeneratorWeb.PageLive.Show do
  use GeneratorWeb, :live_view

  alias Generator.Pages
  alias Generator.Sites

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    {:ok, assign(socket, :site, Sites.get_site!(site_id)),
     layout: {GeneratorWeb.LayoutView, "preview.html"}}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:page, Pages.get_page!(id))}
  end

  defp page_title(:show), do: "Show Page"
  defp page_title(:edit), do: "Edit Page"
end
