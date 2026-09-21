defmodule ShopWeb.Components.ProductCard do
  @moduledoc """
  Provides a product card component with variants for different display contexts.
  """

  use Phoenix.Component

  alias Shop.Catalog.Product
  alias ShopWeb.ProductHTML

  @doc """
  Renders a product card.

  ## Variants

  * `:card` - Full card for grid listings (default)
  * `:compact` - Compact card for related products

  ## Examples

      <.product_card product={@product} variant={:card} />
      <.product_card product={@product} variant={:compact} />
  """
  attr :product, Product, required: true
  attr :variant, :atom, values: [:card, :compact], default: :card
  attr :on_click, :any, doc: "JS navigate or push event"

  def product_card(assigns) do
    variant = assigns.variant

    case variant do
      :card -> render_card(assigns)
      :compact -> render_compact(assigns)
    end
  end

  defp render_card(assigns) do
    ~H"""
    <div class="group relative flex flex-col justify-between rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm transition hover:shadow-md hover:border-zinc-300">
      <div>
        <div class="flex items-center justify-between gap-2">
          <.link navigate={"/categories/#{@product.category.slug}"} class="inline-block">
            <span class="rounded-full bg-zinc-100 px-2.5 py-0.5 text-xs font-medium text-zinc-700 group-hover:bg-zinc-200 transition">
              {@product.category.name}
            </span>
          </.link>
          <ProductHTML.stock_badge stock={@product.stock} />
        </div>

        <h3 class="mt-3 text-lg font-semibold text-zinc-900 line-clamp-1">
          <.link navigate={"/p/#{@product.slug}"} class="hover:text-zinc-600 transition">
            {@product.name}
          </.link>
        </h3>

        <p class="mt-1 text-sm text-zinc-500 line-clamp-2">
          {@product.description || "Sin descripción disponible."}
        </p>
      </div>

      <div class="mt-5 border-t border-zinc-100 pt-4">
        <div class="flex items-center justify-between">
          <span class="text-xl font-bold tracking-tight text-zinc-900">
            {ProductHTML.format_price(@product.price)}
          </span>
          <div class="flex items-center gap-2">
            <.link
              navigate={"/p/#{@product.slug}/edit"}
              class="rounded-md border border-zinc-200 px-2.5 py-1 text-xs font-medium text-zinc-700 hover:bg-zinc-50"
            >
              Editar
            </.link>
            <.link
              navigate={"/p/#{@product.slug}"}
              class="rounded-md bg-zinc-900 px-2.5 py-1 text-xs font-medium text-white hover:bg-zinc-700"
            >
              Ver
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_compact(assigns) do
    ~H"""
    <div class="group flex flex-col rounded-xl border border-zinc-200 bg-white p-3 shadow-sm transition hover:shadow hover:border-zinc-300">
      <div class="flex items-center justify-between gap-1">
        <span class="rounded bg-zinc-100 px-1.5 py-0.5 text-[10px] font-medium text-zinc-600 group-hover:bg-zinc-200 transition line-clamp-1">
          {@product.category.name}
        </span>
        <ProductHTML.stock_badge stock={@product.stock} />
      </div>

      <h4 class="mt-2 text-sm font-semibold text-zinc-900 line-clamp-1">
        <.link navigate={"/p/#{@product.slug}"} class="hover:text-zinc-600 transition">
          {@product.name}
        </.link>
      </h4>

      <p class="mt-1 text-[11px] text-zinc-500 line-clamp-2 flex-1">
        {@product.description || "Sin descripción."}
      </p>

      <div class="mt-2 pt-2 border-t border-zinc-100 flex items-center justify-between">
        <span class="text-lg font-bold text-zinc-900">
          {ProductHTML.format_price(@product.price)}
        </span>
        <.link
          navigate={"/p/#{@product.slug}"}
          class="text-xs font-medium text-zinc-600 hover:text-zinc-900 underline"
        >
          Ver detalle
        </.link>
      </div>
    </div>
    """
  end
end
