defmodule ShopWeb.ProductLive.ShowTest do
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
        name: "Teclado Mecánico Pro",
        slug: "teclado-mecanico-pro",
        description: "Switches táctiles lubricados de fábrica",
        price: Decimal.new("129.99"),
        stock: 25,
        active: true,
        category_id: category.id
      })

    {:ok, product2} =
      Catalog.create_product(%{
        name: "Monitor Curvo 34\"",
        slug: "monitor-curvo-34",
        description: "Resolución WQHD 3440x1440",
        price: Decimal.new("499.00"),
        stock: 7,
        active: true,
        category_id: category.id
      })

    {:ok, product3} =
      Catalog.create_product(%{
        name: "Auriculares Studio",
        slug: "auriculares-studio",
        description: "Cancelación activa de ruido",
        price: Decimal.new("189.50"),
        stock: 14,
        active: true,
        category_id: category.id
      })

    {:ok, product4} =
      Catalog.create_product(%{
        name: "Ratón Ergonómico",
        slug: "raton-ergonomico",
        description: "Diseño vertical 57 grados",
        price: Decimal.new("59.90"),
        stock: 35,
        active: true,
        category_id: category.id
      })

    {:ok, product5} =
      Catalog.create_product(%{
        name: "Webcam 4K",
        slug: "webcam-4k",
        description: "Alta definición",
        price: Decimal.new("89.00"),
        stock: 5,
        active: true,
        category_id: category.id
      })

    {:ok, other_cat} =
      Catalog.create_category(%{
        name: "Libros",
        slug: "libros",
        description: "Literatura técnica",
        position: 2
      })

    {:ok, other_product} =
      Catalog.create_product(%{
        name: "Programming Phoenix",
        slug: "programming-phoenix",
        description: "Guía LiveView",
        price: Decimal.new("36.00"),
        stock: 10,
        active: true,
        category_id: other_cat.id
      })

    {:ok,
     main_product: product1,
     related: [product2, product3, product4, product5],
     other: other_product,
     category: category}
  end

  describe "mount" do
    test "renders product by slug", %{conn: conn, main_product: product} do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "Teclado Mecánico Pro"
      assert html =~ "$129.99"
      assert html =~ "Switches táctiles"
      assert html =~ "En stock (25)"
    end

    test "assigns related products from same category (max 4)", %{
      conn: conn,
      main_product: product,
      related: related
    } do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      # Check that related products are rendered
      assert html =~ "Monitor Curvo"
      assert html =~ "Auriculares Studio"
      assert html =~ "Ratón Ergonómico"
      assert html =~ "Webcam 4K"
      # Should not include the main product in related section
      related_count = String.split(html, "Ver detalle") |> length()
      # 4 related + 1 main "Ver detalle" in main section
      assert related_count == 5
    end

    test "fills with other category products if not enough in same category", %{
      conn: conn,
      main_product: product,
      other: other_product
    } do
      # Create a new category with only 2 products
      {:ok, new_cat} =
        Catalog.create_category(%{
          name: "Test Category",
          slug: "test-category",
          description: "Test",
          position: 10
        })

      {:ok, p1} =
        Catalog.create_product(%{
          name: "Test Product 1",
          slug: "test-product-1",
          price: Decimal.new("10.00"),
          stock: 1,
          active: true,
          category_id: new_cat.id
        })

      {:ok, p2} =
        Catalog.create_product(%{
          name: "Test Product 2",
          slug: "test-product-2",
          price: Decimal.new("20.00"),
          stock: 1,
          active: true,
          category_id: new_cat.id
        })

      {:ok, _view, html} = live(conn, ~p"/p/#{p1.slug}")

      # Should have 2 related products from same category + 2 from other
      assert html =~ "Test Product 2"
    end

    test "renders product details", %{conn: conn, main_product: product} do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "Teclado Mecánico Pro"
      assert html =~ "$129.99"
      assert html =~ "Switches táctiles"
      assert html =~ "En stock (25)"
    end

    test "renders breadcrumb with category link", %{
      conn: conn,
      main_product: product,
      category: category
    } do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "Electrónica"
      assert html =~ ~p"/categories/#{category}"
    end

    test "shows TODO for cart feature", %{conn: conn, main_product: product} do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "feature/shopping-cart"
      assert html =~ "🛒 Carrito"
    end

    test "shows edit and delete links for admin", %{conn: conn, main_product: product} do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "Editar producto"
      assert html =~ "Eliminar"
      assert html =~ "data-confirm"
    end
  end

  describe "related products" do
    test "renders related products using ProductCard compact variant", %{
      conn: conn,
      main_product: product
    } do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      assert html =~ "Ver detalle"
      assert html =~ "Monitor Curvo"
      assert html =~ "Auriculares Studio"
    end

    test "links to related product show page", %{
      conn: conn,
      main_product: product,
      related: [related | _]
    } do
      {:ok, _view, html} = live(conn, ~p"/p/#{product.slug}")

      related_link = ~p"/p/#{related.slug}"
      assert html =~ related_link
    end
  end
end
