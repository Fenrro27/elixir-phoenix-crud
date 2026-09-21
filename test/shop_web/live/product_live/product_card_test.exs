defmodule ShopWeb.Components.ProductCardTest do
  use ShopWeb.LiveViewCase

  alias Shop.Catalog
  alias Shop.Catalog.{Category, Product}
  alias ShopWeb.Components.ProductCard

  setup do
    {:ok, category} =
      Catalog.create_category(%{
        name: "Electrónica",
        slug: "electronica",
        description: "Gadgets",
        position: 1
      })

    {:ok, product} =
      Catalog.create_product(%{
        name: "Teclado Test",
        slug: "teclado-test",
        description: "Descripción de prueba",
        price: Decimal.new("99.99"),
        stock: 15,
        active: true,
        category_id: category.id
      })

    {:ok, product: product, category: category}
  end

  test "product_card function exists and returns Rendered struct for :card variant", %{
    product: product
  } do
    rendered = ProductCard.product_card(%{product: product, variant: :card})

    assert rendered.__struct__ == Phoenix.LiveView.Rendered
    assert is_list(rendered.static)
    assert is_function(rendered.dynamic)
  end

  test "product_card function returns Rendered struct for :compact variant", %{product: product} do
    rendered = ProductCard.product_card(%{product: product, variant: :compact})

    assert rendered.__struct__ == Phoenix.LiveView.Rendered
    assert is_list(rendered.static)
    assert is_function(rendered.dynamic)
  end

  describe "variant :card - static structure" do
    test "renders card wrapper structure", %{product: product} do
      rendered = ProductCard.product_card(%{product: product, variant: :card})
      static_content = rendered.static |> Enum.join("")

      assert static_content =~ "group relative flex flex-col"
      assert static_content =~ "rounded-2xl border border-zinc-200"
    end
  end

  describe "variant :compact - static structure" do
    test "renders compact card wrapper structure", %{product: product} do
      rendered = ProductCard.product_card(%{product: product, variant: :compact})
      static_content = rendered.static |> Enum.join("")

      assert static_content =~ "group flex flex-col"
      refute static_content =~ "Editar"
    end
  end
end
