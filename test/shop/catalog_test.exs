defmodule Shop.CatalogTest do
  use Shop.DataCase

  alias Shop.Catalog
  alias Shop.Catalog.{Category, Product}

  describe "categories" do
    @update_category_attrs %{name: "Electrónica y Hogar", description: "Actualizado", position: 2}
    @invalid_category_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      unique = System.unique_integer([:positive])

      {:ok, category} =
        attrs
        |> Enum.into(%{
          name: "Electrónica #{unique}",
          slug: "electronica-#{unique}",
          description: "Gadgets y computación",
          position: 1
        })
        |> Catalog.create_category()

      category
    end

    test "list_categories/0 returns all categories ordered by position and name" do
      cat1 = category_fixture(%{name: "Zapatillas", slug: "zapatillas", position: 2})
      cat2 = category_fixture(%{name: "Audio", slug: "audio", position: 1})

      categories = Catalog.list_categories()

      # Find positions of our test categories in the full list
      cat1_index = Enum.find_index(categories, &(&1.id == cat1.id))
      cat2_index = Enum.find_index(categories, &(&1.id == cat2.id))

      # cat2 (position: 1) should come before cat1 (position: 2)
      assert cat2_index < cat1_index
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category!(category.id).id == category.id
    end

    test "get_category_by_slug/1 returns the category with given slug" do
      category = category_fixture(%{name: "Audio y Sonido", slug: "audio-y-sonido"})
      assert Catalog.get_category_by_slug("audio-y-sonido").id == category.id
      assert Catalog.get_category_by_slug("inexistente") == nil
    end

    test "create_category/1 with valid data creates a category and auto-generates slug" do
      attrs = %{name: "Electrónica", description: "Gadgets y computación", position: 1}
      assert {:ok, %Category{} = category} = Catalog.create_category(attrs)
      assert category.name == "Electrónica"
      assert category.slug == "electronica"
      assert category.description == "Gadgets y computación"
      assert category.position == 1
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_category_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      assert {:ok, %Category{} = updated} =
               Catalog.update_category(category, @update_category_attrs)

      assert updated.name == "Electrónica y Hogar"
      assert updated.description == "Actualizado"
      assert updated.position == 2
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    @invalid_product_attrs %{name: nil, price: nil, stock: -5}

    def product_fixture(attrs \\ %{}) do
      unique = System.unique_integer([:positive])

      category =
        case attrs[:category_id] do
          nil -> category_fixture()
          id -> %Category{id: id}
        end

      valid_attrs = %{
        name: "Teclado Mecánico #{unique}",
        slug: "teclado-mecanico-#{unique}",
        description: "Teclado con switches táctiles",
        price: Decimal.new("99.99"),
        stock: 10,
        active: true,
        category_id: category.id
      }

      {:ok, product} =
        attrs
        |> Enum.into(valid_attrs)
        |> Catalog.create_product()

      Catalog.get_product!(product.id)
    end

    test "list_products/1 returns all products" do
      product = product_fixture()
      products = Catalog.list_products()
      assert product in products
    end

    test "list_products/1 filters by category_id" do
      cat1 = category_fixture(%{name: "Cat 1", slug: "cat-1"})
      cat2 = category_fixture(%{name: "Cat 2", slug: "cat-2"})

      p1 = product_fixture(%{name: "Prod 1", slug: "prod-1", category_id: cat1.id})
      _p2 = product_fixture(%{name: "Prod 2", slug: "prod-2", category_id: cat2.id})

      assert Catalog.list_products(%{"category_id" => to_string(cat1.id)}) == [p1]
    end

    test "list_products/1 filters by search term" do
      _p1 = product_fixture(%{name: "Monitor LED", slug: "monitor-led"})
      p2 = product_fixture(%{name: "Mouse Gamer", slug: "mouse-gamer"})

      assert Catalog.list_products(%{"search" => "Gamer"}) == [p2]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product!(product.id).id == product.id
    end

    test "get_product_by_slug/1 returns the product with given slug" do
      product = product_fixture(%{name: "Webcam 4K", slug: "webcam-4k"})
      assert Catalog.get_product_by_slug("webcam-4k").id == product.id
      assert Catalog.get_product_by_slug("no-existe") == nil
    end

    test "create_product/1 with valid data creates a product" do
      category = category_fixture()

      valid_attrs = %{
        name: "Micrófono USB",
        description: "Condensador cardioide",
        price: "49.50",
        stock: 15,
        active: true,
        category_id: category.id
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "Micrófono USB"
      assert product.slug == "microfono-usb"
      assert product.price == Decimal.new("49.50")
      assert product.stock == 15
      assert product.active == true
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_product_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "Teclado RGB Pro", price: "120.00", stock: 5}

      assert {:ok, %Product{} = updated} = Catalog.update_product(product, update_attrs)
      assert updated.name == "Teclado RGB Pro"
      assert updated.price == Decimal.new("120.00")
      assert updated.stock == 5
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "update_stock/2 updates stock or returns insufficient error" do
      product = product_fixture(%{stock: 5})

      assert {:ok, updated} = Catalog.update_stock(product, -3)
      assert updated.stock == 2

      assert {:error, :insufficient_stock} = Catalog.update_stock(updated, -5)
    end
  end
end
