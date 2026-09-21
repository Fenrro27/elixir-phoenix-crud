# Script for populating the database with initial catalog data.
# Run with: mix run priv/repo/seeds.exs

alias Shop.Catalog

IO.puts("==> Populando base de datos con categorías...")

categories_data = [
  %{
    name: "Tecnología y Electrónica",
    slug: "tecnologia-y-electronica",
    description: "Dispositivos, computación, periféricos y gadgets modernos",
    position: 1
  },
  %{
    name: "Ropa y Moda",
    slug: "ropa-y-moda",
    description: "Prendas de vestir, calzado y accesorios de diseño",
    position: 2
  },
  %{
    name: "Hogar y Decoración",
    slug: "hogar-y-decoracion",
    description: "Muebles ergonómicos, iluminación y artículos de cocina",
    position: 3
  },
  %{
    name: "Libros y Aprendizaje",
    slug: "libros-y-aprendizaje",
    description: "Literatura técnica, programación funcional y desarrollo profesional",
    position: 4
  }
]

created_categories =
  Enum.map(categories_data, fn cat_attrs ->
    case Catalog.get_category_by_slug(cat_attrs.slug) do
      nil ->
        {:ok, cat} = Catalog.create_category(cat_attrs)
        IO.puts("  ✓ Creada categoría: #{cat.name}")
        cat

      existing ->
        IO.puts("  · Categoría existente: #{existing.name}")
        existing
    end
  end)

cat_by_slug = Map.new(created_categories, fn cat -> {cat.slug, cat} end)

IO.puts("\n==> Populando productos de muestra...")

products_data = [
  %{
    name: "Teclado Mecánico Inalámbrico Pro",
    slug: "teclado-mecanico-inalambrico-pro",
    description:
      "Switches táctiles lubricados de fábrica, retroiluminación RGB configurable, chasis de aluminio y conectividad Bluetooth / 2.4GHz.",
    price: Decimal.new("129.99"),
    stock: 25,
    active: true,
    category_id: cat_by_slug["tecnologia-y-electronica"].id
  },
  %{
    name: "Monitor Curvo Ultrawide 34\"",
    slug: "monitor-curvo-ultrawide-34",
    description:
      "Resolución WQHD 3440x1440, tasa de refresco de 144Hz, curvatura 1500R y panel IPS para máxima productividad.",
    price: Decimal.new("499.00"),
    stock: 7,
    active: true,
    category_id: cat_by_slug["tecnologia-y-electronica"].id
  },
  %{
    name: "Auriculares Noise-Cancelling Studio",
    slug: "auriculares-noise-cancelling-studio",
    description:
      "Cancelación activa de ruido híbrida, hasta 40 horas de autonomía, micrófonos con filtro beamforming para videollamadas nítidas.",
    price: Decimal.new("189.50"),
    stock: 14,
    active: true,
    category_id: cat_by_slug["tecnologia-y-electronica"].id
  },
  %{
    name: "Ratón Ergonómico Vertical",
    slug: "raton-ergonomico-vertical",
    description:
      "Diseño ergonómico a 57 grados que reduce la fatiga muscular de la muñeca. Sensor de alta precisión 4000 DPI.",
    price: Decimal.new("59.90"),
    stock: 35,
    active: true,
    category_id: cat_by_slug["tecnologia-y-electronica"].id
  },
  %{
    name: "Sudadera Minimalista 'Functional Flow'",
    slug: "sudadera-minimalista-functional-flow",
    description:
      "100% algodón orgánico peinado de 350g, corte relajado y bordado sutil en pecho.",
    price: Decimal.new("48.00"),
    stock: 40,
    active: true,
    category_id: cat_by_slug["ropa-y-moda"].id
  },
  %{
    name: "Chaqueta Cortavientos Técnica Impermeable",
    slug: "chaqueta-cortavientos-impermeable",
    description:
      "Membrana transpirable de triple capa, costuras termoselladas y bolsillos con cremalleras resistentes al agua.",
    price: Decimal.new("89.00"),
    stock: 12,
    active: true,
    category_id: cat_by_slug["ropa-y-moda"].id
  },
  %{
    name: "Lámpara de Escritorio LED con Carga Inalámbrica",
    slug: "lampara-escritorio-led-inalambrica",
    description:
      "Temperatura de color ajustable (2700K a 6500K), control táctil y base de carga Qi de 15W integrada.",
    price: Decimal.new("42.50"),
    stock: 20,
    active: true,
    category_id: cat_by_slug["hogar-y-decoracion"].id
  },
  %{
    name: "Taza Térmica de Doble Pared 450ml",
    slug: "taza-termica-doble-pared-450ml",
    description:
      "Acero inoxidable 18/8 de grado alimenticio. Mantiene el café caliente hasta por 6 horas y bebidas frías hasta por 12 horas.",
    price: Decimal.new("22.00"),
    stock: 60,
    active: true,
    category_id: cat_by_slug["hogar-y-decoracion"].id
  },
  %{
    name: "Programming Phoenix LiveView",
    slug: "programming-phoenix-liveview-book",
    description:
      "Guía completa para construir aplicaciones web reactivas en tiempo real sin escribir JavaScript pesado.",
    price: Decimal.new("36.00"),
    stock: 18,
    active: true,
    category_id: cat_by_slug["libros-y-aprendizaje"].id
  },
  %{
    name: "Designing Elixir Systems with OTP",
    slug: "designing-elixir-systems-otp-book",
    description:
      "Aprende a diseñar sistemas concurrentes, tolerantes a fallos y distribuidos utilizando los principios de OTP.",
    price: Decimal.new("34.50"),
    stock: 5,
    active: true,
    category_id: cat_by_slug["libros-y-aprendizaje"].id
  }
]

Enum.each(products_data, fn prod_attrs ->
  case Catalog.get_product_by_slug(prod_attrs.slug) do
    {:error, _} ->
      {:ok, prod} = Catalog.create_product(prod_attrs)
      IO.puts("  ✓ Creado producto: #{prod.name}")

    prod when is_struct(prod) ->
      IO.puts("  · Producto existente: #{prod.name}")

    nil ->
      {:ok, prod} = Catalog.create_product(prod_attrs)
      IO.puts("  ✓ Creado producto: #{prod.name}")
  end
end)

IO.puts("\n==> Catálogo poblado exitosamente.")
