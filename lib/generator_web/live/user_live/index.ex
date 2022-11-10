defmodule GeneratorWeb.UserLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, list_users())}
  end

  defp list_users() do
    Accounts.list_users()
  end
end
