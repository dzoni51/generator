defmodule GeneratorWeb.ThreadLive.Index do
  use GeneratorWeb, :live_view

  alias Generator.Threads
  alias Generator.Threads.Thread
  alias Generator.Messages

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:threads, list_threads(Threads.default_thread_filter()))
     |> assign(:thread, nil)
     |> assign(:term, "")
     |> assign(:new, true)
     |> assign(:archived, false)
     |> assign(:all, false)
     |> assign(:filter_values, Threads.default_thread_filter())}
  end

  @impl true
  def handle_event("show-messages", %{"thread-id" => thread_id}, socket) do
    {:noreply,
     socket
     |> assign(:thread, Threads.admin_get_thread(thread_id))}
  end

  @impl true
  def handle_event("save", %{"message" => message_params}, socket) do
    message_params
    |> Map.put("sent_by", Messages.support_email_address())
    |> Map.put("thread_id", socket.assigns.thread.id)
    |> Messages.create_message()
    |> case do
      {:ok, _message} ->
        {:ok, thread} = Threads.set_needs_reply(socket.assigns.thread.id, false)

        {:noreply,
         socket
         |> put_flash(:info, "Message sent!")
         |> assign(:thread, thread)
         |> assign(:threads, list_threads(socket.assigns.filter_values))}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error while trying to send the message")
         |> assign(:thread, Threads.admin_get_thread(socket.assigns.thread.id))}
    end
  end

  @impl true
  def handle_event("archive", _, socket) do
    {:ok, thread} = Threads.archive_thread(socket.assigns.thread.id)

    {:noreply,
     socket
     |> assign(:thread, thread)
     |> assign(:threads, list_threads(socket.assigns.filter_values))}
  end

  @impl true
  def handle_event("unarchive", _, socket) do
    {:ok, thread} = Threads.unarchive_thread(socket.assigns.thread.id)

    {:noreply,
     socket
     |> assign(:thread, thread)
     |> assign(:threads, list_threads(socket.assigns.filter_values))}
  end

  @impl true
  def handle_event(
        "search_change",
        %{"_target" => ["search", "term"], "search" => %{"term" => term}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:threads, Threads.search_threads(term))
     |> assign(:term, term)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter, "value" => "on"}, socket) do
    atom_filter = String.to_atom(filter)
    new_filter_values = [atom_filter | socket.assigns.filter_values]

    {:noreply,
     socket
     |> assign(atom_filter, true)
     |> assign(:threads, list_threads(new_filter_values))
     |> assign(:filter_values, new_filter_values)}
  end

  # ! This turns filter off
  @impl true
  def handle_event("filter", %{"filter" => filter}, socket) do
    atom_filter = String.to_atom(filter)

    new_filter_values =
      Enum.reject(socket.assigns.filter_values, fn value -> value == atom_filter end)

    {:noreply,
     socket
     |> assign(atom_filter, false)
     |> assign(:threads, list_threads(new_filter_values))
     |> assign(:filter_values, new_filter_values)}
  end

  @impl true
  def handle_event("search_submit", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  # ! New, unreplied, replied, archived
  def add_class_to_list_element(%Thread{messages: messages, archived: archived?}) do
    cond do
      new?(messages) ->
        "py-4 bg-red-300 text-red-700 hover:bg-red-100 hover:text-red-800"

      unreplied?(messages) ->
        "py-4 bg-blue-300 text-blue-700 hover:bg-blue-100 hover:text-blue-800"

      archived? ->
        "py-4 bg-yellow-300 text-yellow-700 hover:bg-yellow-100 hover:text-yellow-800"

      true ->
        "py-4 bg-green-300 text-green-700 hover:bg-green-100 hover:text-green-800"
    end
  end

  def add_class_to_list_element(_), do: ""

  defp new?(messages) do
    not Enum.any?(messages, fn message -> message.sent_by == Messages.support_email_address() end)
  end

  defp unreplied?(messages) do
    List.last(messages).sent_by != Messages.support_email_address()
  end

  defp list_threads(options) do
    Threads.list_threads(options)
  end
end
