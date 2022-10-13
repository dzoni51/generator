defmodule GeneratorWeb.ComponentLiveTest do
  use GeneratorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Generator.ComponentsFixtures

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}

  defp create_component(_) do
    component = component_fixture()
    %{component: component}
  end

  describe "Index" do
    setup [:create_component]

    test "lists all components", %{conn: conn, component: component} do
      {:ok, _index_live, html} = live(conn, Routes.component_index_path(conn, :index))

      assert html =~ "Listing Components"
      assert html =~ component.code
    end

    test "saves new component", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.component_index_path(conn, :index))

      assert index_live |> element("a", "New Component") |> render_click() =~
               "New Component"

      assert_patch(index_live, Routes.component_index_path(conn, :new))

      assert index_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#component-form", component: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.component_index_path(conn, :index))

      assert html =~ "Component created successfully"
      assert html =~ "some code"
    end

    test "updates component in listing", %{conn: conn, component: component} do
      {:ok, index_live, _html} = live(conn, Routes.component_index_path(conn, :index))

      assert index_live |> element("#component-#{component.id} a", "Edit") |> render_click() =~
               "Edit Component"

      assert_patch(index_live, Routes.component_index_path(conn, :edit, component))

      assert index_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#component-form", component: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.component_index_path(conn, :index))

      assert html =~ "Component updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes component in listing", %{conn: conn, component: component} do
      {:ok, index_live, _html} = live(conn, Routes.component_index_path(conn, :index))

      assert index_live |> element("#component-#{component.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#component-#{component.id}")
    end
  end

  describe "Show" do
    setup [:create_component]

    test "displays component", %{conn: conn, component: component} do
      {:ok, _show_live, html} = live(conn, Routes.component_show_path(conn, :show, component))

      assert html =~ "Show Component"
      assert html =~ component.code
    end

    test "updates component within modal", %{conn: conn, component: component} do
      {:ok, show_live, _html} = live(conn, Routes.component_show_path(conn, :show, component))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Component"

      assert_patch(show_live, Routes.component_show_path(conn, :edit, component))

      assert show_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#component-form", component: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.component_show_path(conn, :show, component))

      assert html =~ "Component updated successfully"
      assert html =~ "some updated code"
    end
  end
end
