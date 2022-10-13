defmodule GeneratorWeb.ComponentLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Components
  alias Generator.Components.Component

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :components, list_components())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Component")
    |> assign(:component, Components.get_component!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Component")
    |> assign(:component, %Component{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Components")
    |> assign(:component, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    component = Components.get_component!(id)
    {:ok, _} = Components.delete_component(component)

    {:noreply, assign(socket, :components, list_components())}
  end

  defp list_components do
    Components.list_components()
  end
end
