defmodule Generator.Plans do
  @moduledoc """
  The plans context.
  """

  @bussiness "Bussiness"
  @personal "Personal"
  @cms "CMS"

  import Ecto.Query, warn: false
  alias Generator.Repo
  alias Generator.Plans.Plan

  def list_plans(), do: Repo.all(Plan)

  def get_plan!(id), do: Repo.get!(Plan, id)

  def create_plan(attrs), do: Plan.new(attrs) |> Repo.insert()

  def get_plan_name(name) do
    cond do
      name == "bussiness" -> @bussiness
      name == "personal" -> @personal
      name == "cms" -> @cms
      true -> nil
    end
  end

  def get_plan_by_name(name) do
    plan_name = get_plan_name(name)

    Plan
    |> where(name: ^plan_name)
    |> Repo.one()
  end

  def personal(), do: "personal"
  def cms(), do: "cms"
  def bussiness(), do: "bussiness"

  def change_plan(plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  def update_plan(plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end
end
