defmodule GeneratorWeb.UserLive.FormComponent do
  use GeneratorWeb, :live_component

  alias Generator.Accounts
  alias Generator.Accounts.User

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.admin_change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.admin_change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.admin_update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        maybe_update_user_subscription(Accounts.get_user!(user.id))

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp maybe_update_user_subscription(%User{subscription_id: nil}),
    do: {:ok, :user_not_subscribed}

  defp maybe_update_user_subscription(%User{subscription_id: sub_id, custom_plan_price: price}) do
    Braintree.Subscription.update(sub_id, %{price: price})
  end
end
