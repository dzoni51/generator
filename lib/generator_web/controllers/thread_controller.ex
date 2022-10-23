defmodule GeneratorWeb.ThreadController do
  use GeneratorWeb, :controller

  alias Generator.Threads

  def index(conn, _) do
    conn
    |> render("index.html", threads: Threads.list_threads_by_user_id(conn.assigns.current_user.id))
  end

  def create(conn, %{"thread" => thread_params}) do
    thread_params
    |> Map.put("user_id", conn.assigns.current_user.id)
    |> Threads.create_thread()
    |> case do
      {:ok, _thread} ->
        conn
        |> put_flash(:info, "Thread created!")
        |> redirect(to: Routes.thread_path(conn, :index))

      {:error, _cs} ->
        conn
        |> put_flash(:error, "Oops, invalid thread name.")
        |> redirect(to: Routes.thread_path(conn, :index))
    end
  end
end
