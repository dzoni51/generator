defmodule Generator.ComponentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Generator.Components` context.
  """

  @doc """
  Generate a component.
  """
  def component_fixture(attrs \\ %{}) do
    {:ok, component} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name"
      })
      |> Generator.Components.create_component()

    component
  end
end
