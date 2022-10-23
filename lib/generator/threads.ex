defmodule Generator.Threads do
  @moduledoc """
  The threads context.
  """

  import Ecto.Query, warn: false
  alias Generator.Threads.Thread
  alias Generator.Repo
  alias Generator.Messages.Message
  alias Generator.Accounts.User

  def create_thread(attrs) do
    attrs
    |> Thread.new()
    |> Repo.insert()
  end

  def list_threads_by_user_id(user_id) do
    query = from t in Thread, where: t.user_id == ^user_id

    Repo.all(query)
  end

  def get_thread(id, user_id) do
    query = from t in Thread, where: t.id == ^id and t.user_id == ^user_id, preload: :messages

    Repo.one(query)
  end

  def archive_thread(id) do
    with %Thread{} = thread <- admin_get_thread(id) do
      thread
      |> Thread.changeset(%{"archived" => true})
      |> Repo.update()
    end
  end

  def unarchive_thread(id) do
    with %Thread{} = thread <- admin_get_thread(id) do
      thread
      |> Thread.changeset(%{"archived" => false})
      |> Repo.update()
    end
  end

  def search_threads(term) do
    user_query = from u in User, join: t in Thread, on: t.user_id == u.id

    query_value = "%" <> String.trim(term) <> "%"

    query =
      from [u, t] in user_query,
        where: ilike(u.email, ^query_value) or ilike(t.name, ^query_value),
        select: t

    Repo.all(query) |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))
  end

  @new :new
  @archived :archived
  @all :all

  def default_thread_filter(), do: [@new]

  def list_threads(options) do
    new_threads_query = from t in Thread, where: t.needs_reply

    archived_query = from t in Thread, where: t.archived

    cond do
      @all in options ->
        Repo.all(Thread)
        |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))

      @archived in options and @new in options ->
        new_threads =
          Repo.all(new_threads_query)
          |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))

        archived_threads =
          Repo.all(archived_query)
          |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))

        Enum.concat(new_threads, archived_threads)
        |> Enum.uniq()

      @new in options ->
        Repo.all(new_threads_query)
        |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))

      @archived in options ->
        Repo.all(archived_query)
        |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))

      true ->
        []
    end
  end

  def admin_get_thread(thread_id) do
    Thread
    |> Repo.get(thread_id)
    |> Repo.preload(messages: from(m in Message, order_by: [asc: m.inserted_at]))
  end

  def set_needs_reply(id, value) do
    with %Thread{} = thread <- admin_get_thread(id) do
      thread
      |> Thread.changeset(%{"needs_reply" => value})
      |> Repo.update()
    end
  end
end
