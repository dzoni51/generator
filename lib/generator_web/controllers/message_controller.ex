defmodule GeneratorWeb.MessageController do
  use GeneratorWeb, :controller

  alias Generator.Messages
  alias Generator.Threads

  def index(conn, %{"id" => thread_id}) do
    render(conn, "index.html", thread: Threads.get_thread(thread_id, conn.assigns.current_user.id))
  end

  def create(conn, %{"message" => message_params, "id" => thread_id}) do
    message_params
    |> Map.put("sent_by", conn.assigns.current_user.email)
    |> Map.put("thread_id", thread_id)
    |> Messages.create_message()
    |> case do
      {:ok, _message} ->
        Threads.set_needs_reply(thread_id, true)

        conn
        |> put_flash(:info, "Message sent!")
        |> redirect(to: Routes.message_path(conn, :index, thread_id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oops, invalid message body.")
        |> redirect(to: Routes.message_path(conn, :index, thread_id))
    end
  end
end
