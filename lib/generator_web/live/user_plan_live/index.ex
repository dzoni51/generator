defmodule GeneratorWeb.UserPlanLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Accounts
  alias Generator.Accounts.User
  alias Generator.Plans
  alias Generator.Plans.Plan
  alias Generator.Cards
  alias Generator.Transactions

  require Logger

  @impl true
  def mount(%{"user_id" => user_id}, _session, socket) do
    user = Accounts.get_user!(user_id, [:plan])

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:current_plan_name, get_current_plan_name(user))
     |> assign(:transactions, Transactions.list_user_transactions(user.id))
     |> IO.inspect()}
  end

  @impl true
  def handle_event("change-plan", %{"plan" => %{"new_plan" => "no_plan"}}, socket) do
    with {:ok, _sub} <-
           Braintree.Subscription.cancel(socket.assigns.user.subscription_id),
         {:ok, user} <- Accounts.remove_plan(socket.assigns.user) do
      {:noreply,
       socket
       |> put_flash(:info, "Plan removed successfully")
       |> assign(:user, user)
       |> assign(:current_plan_name, get_current_plan_name(user))}
    else
      {:error, %Braintree.ErrorResponse{} = err_response} ->
        Logger.error(
          "Error when trying to remove a subscription for user_id: #{socket.assigns.user.id}, #{inspect(err_response, pretty: true)}"
        )

        {:noreply,
         socket
         |> put_flash(:error, "Braintree error.")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error when trying to remove a plan from our DB.")}
    end

    case Accounts.remove_plan(socket.assigns.user) do
      {:ok, _user} ->
        user = get_user(socket.assigns.user.id)

        {:noreply,
         socket
         |> put_flash(:info, "Plan removed successfully")
         |> assign(:user, user)
         |> assign(:current_plan_name, get_current_plan_name(user))}

      {:error, _cs} ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while trying to remove plan.")}
    end
  end

  @impl true
  def handle_event(
        "change-plan",
        %{"plan" => %{"new_plan" => "custom"}},
        %{assigns: %{user: %User{custom_plan_price: nil}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "Error: Custom plan price is not set!")}
  end

  @impl true
  def handle_event(
        "change-plan",
        %{"plan" => %{"new_plan" => "custom"}},
        %{assigns: %{user: %User{custom_plan_price: price, id: user_id} = user}} = socket
      ) do
    with %Plan{braintree_id: plan_braintree_id, id: plan_id} <-
           Plans.get_plan_by_name("custom"),
         {:ok, sub} =
           Braintree.Subscription.create(%{
             payment_method_token: Cards.get_user_default_payment_token(user_id),
             plan_id: plan_braintree_id,
             price: to_string(price),
             billing_day_of_month: Timex.today().day
           }),
         {:ok, user} <-
           Accounts.apply_plan(user, %{
             "plan_id" => plan_id,
             "subscription_id" => sub.id,
             "plan_started_on" => Date.utc_today(),
             "next_billing_date" => sub.next_billing_date,
             "next_billing_period_amount" => sub.next_billing_period_amount
           }) do
      {:noreply,
       socket
       |> put_flash(:info, "Plan applied successfully")
       |> assign(:user, user)
       |> assign(:current_plan_name, get_current_plan_name(user))}
    else
      {:error, %Braintree.ErrorResponse{} = err_response} ->
        Logger.error(
          "Error when trying to create a subscription for user_id: #{user.id}, #{inspect(err_response, pretty: true)}"
        )

        {:noreply,
         socket
         |> put_flash(:error, "Braintree error")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error when trying to apply plan to our DB.")}
    end
  end

  @impl true
  def handle_event("change-plan", %{"plan" => %{"new_plan" => new_plan_name}}, socket) do
    with %Plan{braintree_id: plan_braintree_id, id: plan_id, price: price} <-
           Plans.get_plan_by_name(new_plan_name),
         {:ok, sub} =
           Braintree.Subscription.create(%{
             payment_method_token: Cards.get_user_default_payment_token(socket.assigns.user.id),
             plan_id: plan_braintree_id,
             price: to_string(price),
             billing_day_of_month: Timex.today().day
           }),
         {:ok, user} <-
           Accounts.apply_plan(socket.assigns.user, %{
             "plan_id" => plan_id,
             "subscription_id" => sub.id,
             "plan_started_on" => Date.utc_today()
           }) do
      {:noreply,
       socket
       |> put_flash(:info, "Plan applied successfully")
       |> assign(:user, user)
       |> assign(:current_plan_name, get_current_plan_name(user))}
    else
      {:error, %Braintree.ErrorResponse{} = err_response} ->
        Logger.error(
          "Error when trying to create a subscription for user_id: #{socket.assigns.user.id}, #{inspect(err_response, pretty: true)}"
        )

        {:noreply,
         socket
         |> put_flash(:error, "Braintree error")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Error when trying to apply plan to our DB.")}
    end
  end

  defp get_current_plan_name(user) do
    Accounts.get_user_plan_name(user)
    |> case do
      nil ->
        "no_plan"

      value ->
        String.downcase(value)
    end
  end

  defp get_user(user_id) do
    Accounts.get_user!(user_id) |> Generator.Repo.preload(:plan)
  end
end
