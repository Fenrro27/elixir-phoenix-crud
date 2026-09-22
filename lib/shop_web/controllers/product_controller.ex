defmodule ShopWeb.ProductController do
  use ShopWeb, :controller

  alias Shop.Catalog
  alias Shop.Catalog.Product

  def index(conn, params) do
    products = Catalog.list_products(params)
    categories = Catalog.list_categories()
    selected_category_id = params["category_id"] || ""
    search_query = params["search"] || ""

    render(conn, :index,
      products: products,
      categories: categories,
      selected_category_id: selected_category_id,
      search_query: search_query
    )
  end

  def new(conn, params) do
    category_id = params["category_id"]
    changeset = Catalog.change_product(%Product{category_id: category_id})
    categories = Catalog.category_select_options()
    render(conn, :new, changeset: changeset, categories: categories)
  end

  def create(conn, %{"product" => product_params}) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Producto creado con éxito.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Catalog.category_select_options()
        render(conn, :new, changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    render(conn, :show, product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    changeset = Catalog.change_product(product)
    categories = Catalog.category_select_options()
    render(conn, :edit, product: product, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalog.get_product!(id)

    case Catalog.update_product(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Producto actualizado con éxito.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Catalog.category_select_options()
        render(conn, :edit, product: product, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    {:ok, _product} = Catalog.delete_product(product)

    conn
    |> put_flash(:info, "Producto eliminado con éxito.")
    |> redirect(to: ~p"/products")
  end
end
