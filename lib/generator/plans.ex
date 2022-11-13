defmodule Generator.Plans do
  @moduledoc """
  The plans context.
  """

  @bussiness "Bussiness"
  @personal "Personal"
  @cms "CMS"
  @bussiness_yearly @bussiness <> " yearly"
  @personal_yearly @personal <> " yearly"
  @cms_yearly @cms <> " yearly"
  @custom "Custom"

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
      name == "bussiness_yearly" -> @bussiness_yearly
      name == "personal_yearly" -> @personal_yearly
      name == "cms_yearly" -> @cms_yearly
      name == "custom" -> @custom
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

  def personal_yearly(), do: "personal_yearly"
  def cms_yearly(), do: "cms_yearly"
  def bussiness_yearly(), do: "bussiness_yearly"

  def custom(), do: "custom"

  def change_plan(plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  def update_plan(plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end
end
