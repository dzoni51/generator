defmodule GeneratorWeb.PlanController do
  use GeneratorWeb, :controller

  alias Generator.Plans

  def index(conn, _params) do
    render(conn, "index.html",
      personal: Plans.get_plan_by_name(Plans.personal()),
      cms: Plans.get_plan_by_name(Plans.cms()),
      bussiness: Plans.get_plan_by_name(Plans.bussiness())
    )
  end
end
