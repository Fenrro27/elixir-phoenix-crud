defmodule ShopWeb.ProductLive.Index do
  use ShopWeb, :live_view

  alias Shop.Catalog

  @impl true
  def mount(_params, _session, socket) do
    categories = Catalog.list_categories()
    products = Catalog.list_products(%{})

    {:ok,
     socket
     |> assign(:categories, categories)
     |> assign(:search_query, "")
     |> assign(:selected_category_id, "")
     |> assign(:sort_by, "newest")
     |> assign(:products_list, products)
     |> stream(:products, products, reset: true)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    search = params["search"] || ""
    category_id = params["category_id"] || ""
    sort = params["sort"] || "newest"

    products =
      Catalog.list_products(%{
        "search" => search,
        "category_id" => category_id,
        "sort" => sort
      })

    {:noreply,
     socket
     |> assign(:search_query, search)
     |> assign(:selected_category_id, category_id)
     |> assign(:sort_by, sort)
     |> assign(:products_list, products)
     |> stream(:products, products, reset: true)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/")}
  end
end
