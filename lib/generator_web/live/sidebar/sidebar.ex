defmodule GeneratorWeb.Sidebar do
  use Phoenix.LiveComponent

  alias GeneratorWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
       <div class="hidden md:fixed md:inset-y-0 md:flex md:w-64 md:flex-col">
        <!-- Sidebar component, swap this element with another sidebar if you like -->
        <div class="flex flex-grow flex-col overflow-y-auto border-r border-gray-200 bg-white pt-5">
        <div class="flex flex-shrink-0 items-center px-4">
          <img class="h-8 w-auto" src="https://tailwindui.com/img/logos/mark.svg?color=indigo&shade=600" alt="">
        </div>
        <div class="mt-5 flex flex-grow flex-col">
          <nav class="flex-1 space-y-1 px-2 pb-4">
                <a href="#" phx-click="change-screen" phx-target={@myself} phx-value-screen="sites" class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md">
                  <svg class="text-gray-400 group-hover:text-gray-500 mr-4 flex-shrink-0 h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z" />
                  </svg>
                  Sites
                </a>
          </nav>
        </div>
      </div>
      </div>
    """
  end

  def handle_event("change-screen", %{"screen" => screen}, socket) do
    {:noreply,
     socket
     |> assign(:screen, screen)
     |> redirect()}
  end

  defp redirect(socket) do
    case socket.assigns.screen do
      "sites" -> push_redirect(socket, to: Routes.site_index_path(socket, :index))
      _ -> push_redirect(socket, to: "/")
    end
  end
end
