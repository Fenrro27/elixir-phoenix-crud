defmodule ShopWeb.ProductLive.IndexTest do
  use ShopWeb.LiveViewCase, async: true

  alias Shop.Catalog
  alias Shop.Catalog.{Category, Product}

  setup do
    {:ok, category} =
      Catalog.create_category(%{
        name: "Electrónica",
        slug: "electronica",
        description: "Gadgets y computación",
        position: 1
      })

    {:ok, product1} =
      Catalog.create_product(%{
        name: "Teclado Mecánico",
        slug: "teclado-mecanico",
        description: "Switches táctiles",
        price: Decimal.new("129.99"),
        stock: 25,
        active: true,
        category_id: category.id
      })

    {:ok, product2} =
      Catalog.create_product(%{
        name: "Monitor 4K",
        slug: "monitor-4k",
        description: "Pantalla ultra HD",
        price: Decimal.new("499.00"),
        stock: 7,
        active: true,
        category_id: category.id
      })

    {:ok, product3} =
      Catalog.create_product(%{
        name: "Mouse Gamer",
        slug: "mouse-gamer",
        description: "Alta precisión",
        price: Decimal.new("59.90"),
        stock: 35,
        active: true,
        category_id: category.id
      })

    {:ok, category: category, products: [product1, product2, product3]}
  end

  describe "mount" do
    test "renders products list", %{conn: conn, products: products} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Teclado Mecánico"
      assert html =~ "Monitor 4K"
      assert html =~ "Mouse Gamer"
    end

    test "assigns categories for filter", %{conn: conn, category: category} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Electrónica"
    end

    test "shows default filter values in form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Todas las categorías"
      assert html =~ "Más nuevos"
    end
  end
end
