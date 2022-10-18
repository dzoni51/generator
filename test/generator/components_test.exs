defmodule Generator.ComponentsTest do
  use Generator.DataCase

  alias Generator.Components

  describe "components" do
    alias Generator.Components.Component

    import Generator.ComponentsFixtures

    @invalid_attrs %{code: nil, name: nil}

    test "list_components/0 returns all components" do
      component = component_fixture()
      assert Components.list_components() == [component]
    end

    test "get_component!/1 returns the component with given id" do
      component = component_fixture()
      assert Components.get_component!(component.id) == component
    end

    test "create_component/1 with valid data creates a component" do
      valid_attrs = %{code: "some code", name: "some name"}

      assert {:ok, %Component{} = component} = Components.create_component(valid_attrs)
      assert component.code == "some code"
      assert component.name == "some name"
    end

    test "create_component/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Components.create_component(@invalid_attrs)
    end

    test "update_component/2 with valid data updates the component" do
      component = component_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name"}

      assert {:ok, %Component{} = component} =
               Components.update_component(component, update_attrs)

      assert component.code == "some updated code"
      assert component.name == "some updated name"
    end

    test "update_component/2 with invalid data returns error changeset" do
      component = component_fixture()
      assert {:error, %Ecto.Changeset{}} = Components.update_component(component, @invalid_attrs)
      assert component == Components.get_component!(component.id)
    end

    test "delete_component/1 deletes the component" do
      component = component_fixture()
      assert {:ok, %Component{}} = Components.delete_component(component)
      assert_raise Ecto.NoResultsError, fn -> Components.get_component!(component.id) end
    end

    test "change_component/1 returns a component changeset" do
      component = component_fixture()
      assert %Ecto.Changeset{} = Components.change_component(component)
    end
  end
end
