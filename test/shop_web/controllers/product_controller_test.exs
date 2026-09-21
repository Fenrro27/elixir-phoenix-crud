defmodule ShopWeb.ProductControllerTest do
  use ShopWeb.ConnCase

  alias Shop.Catalog

  def fixture(:category) do
    {:ok, category} =
      Catalog.create_category(%{
        name: "Informática",
        description: "Equipos de computación",
        position: 1
      })

    category
  end

  def fixture(:product, category) do
    {:ok, product} =
      Catalog.create_product(%{
        name: "Portátil Ultra",
        description: "Portátil ligero de 14 pulgadas",
        price: "999.00",
        stock: 5,
        active: true,
        category_id: category.id
      })

    Catalog.get_product!(product.id)
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/products")
      assert html_response(conn, 200) =~ "Catálogo de Productos"
    end

    test "filters products by search", %{conn: conn} do
      category = fixture(:category)
      fixture(:product, category)

      conn = get(conn, ~p"/products?search=Ultra")
      assert html_response(conn, 200) =~ "Portátil Ultra"

      conn = get(conn, ~p"/products?search=Inexistente")
      assert html_response(conn, 200) =~ "No se encontraron productos"
    end
  end

  describe "new product" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/products/new")
      assert html_response(conn, 200) =~ "Nuevo Producto"
    end
  end

  describe "create product" do
    test "redirects to show when data is valid", %{conn: conn} do
      category = fixture(:category)

      create_attrs = %{
        name: "Tablet Pro 11",
        description: "Pantalla OLED",
        price: "450.00",
        stock: 8,
        active: true,
        category_id: category.id
      }

      conn = post(conn, ~p"/products", product: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/products/#{id}"

      conn = get(conn, ~p"/products/#{id}")
      assert html_response(conn, 200) =~ "Tablet Pro 11"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/products", product: %{name: nil, price: -10})
      assert html_response(conn, 200) =~ "Nuevo Producto"
    end
  end

  describe "edit product" do
    test "renders form for editing chosen product", %{conn: conn} do
      category = fixture(:category)
      product = fixture(:product, category)

      conn = get(conn, ~p"/products/#{product}/edit")
      assert html_response(conn, 200) =~ "Editar Producto"
    end
  end

  describe "update product" do
    test "redirects when data is valid", %{conn: conn} do
      category = fixture(:category)
      product = fixture(:product, category)

      update_attrs = %{
        name: "Portátil Ultra Max",
        price: "1099.00",
        stock: 3
      }

      conn = put(conn, ~p"/products/#{product}", product: update_attrs)
      assert redirected_to(conn) == ~p"/products/#{product}"

      conn = get(conn, ~p"/products/#{product}")
      assert html_response(conn, 200) =~ "Portátil Ultra Max"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      category = fixture(:category)
      product = fixture(:product, category)

      conn = put(conn, ~p"/products/#{product}", product: %{price: -100})
      assert html_response(conn, 200) =~ "Editar Producto"
    end
  end

  describe "delete product" do
    test "deletes chosen product", %{conn: conn} do
      category = fixture(:category)
      product = fixture(:product, category)

      conn = delete(conn, ~p"/products/#{product}")
      assert redirected_to(conn) == ~p"/products"

      assert_raise Ecto.NoResultsError, fn ->
        Catalog.get_product!(product.id)
      end
    end
  end
end
