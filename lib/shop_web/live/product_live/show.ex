defmodule ShopWeb.ProductLive.Show do
  use ShopWeb, :live_view

  alias Shop.Catalog

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case Catalog.get_product_by_slug(slug) do
      nil ->
        {:halt, socket |> put_flash(:error, "Producto no encontrado") |> redirect(to: ~p"/")}

      product ->
        related_products = Catalog.get_related_products(product)

        {:ok,
         socket
         |> assign(:product, product)
         |> assign(:related_products, related_products)
         |> assign(:active_image_index, 0)}
    end
  end

  @impl true
  def handle_event("set_active_image", %{"index" => index}, socket) do
    case Integer.parse(index) do
      {value, ""} -> {:noreply, assign(socket, :active_image_index, value)}
      _ -> {:noreply, assign(socket, :active_image_index, 0)}
    end
  end
end
