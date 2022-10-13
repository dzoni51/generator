defmodule GeneratorWeb.ComponentLive.Show do
  use GeneratorWeb, :live_view

  alias Generator.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:component, Components.get_component!(id))}
  end

  defp page_title(:show), do: "Show Component"
  defp page_title(:edit), do: "Edit Component"
end
