defmodule GeneratorWeb.PlanLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Plans

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:plans, get_plans())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit plan")
    |> assign(:plan, Plans.get_plan!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:plan, nil)
  end

  defp get_plans() do
    Plans.list_plans()
  end
end
