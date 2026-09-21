defmodule Shop.Catalog do
  @moduledoc """
  The Catalog context. Manages categories and products.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Catalog.{Category, Product}

  ## Categories

  @doc """
  Returns the list of categories ordered by position and name.
  """
  def list_categories do
    Category
    |> order_by([c], asc: c.position, asc: c.name)
    |> Repo.all()
  end

  @doc """
  Returns a list of tuples formatted for form selects: `[{"Name", id}, ...]`.
  """
  def category_select_options do
    Category
    |> order_by([c], asc: c.name)
    |> select([c], {c.name, c.id})
    |> Repo.all()
  end

  @doc """
  Gets a single category.
  Raises `Ecto.NoResultsError` if the Category does not exist.
  """
  def get_category!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload([:parent, :children, products: from(p in Product, order_by: [asc: p.name])])
  end

  @doc """
  Gets a category by its unique slug.
  Returns nil if not found.
  """
  def get_category_by_slug(slug) when is_binary(slug) do
    Category
    |> Repo.get_by(slug: slug)
    |> Repo.preload([:parent, :children, products: from(p in Product, order_by: [asc: p.name])])
  end

  @doc """
  Creates a category.
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.
  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  ## Products

  @doc """
  Returns a list of products with optional filters.

  ## Options:
    * `:category_id` / `"category_id"` - Filter by category ID
    * `:search` / `"search"` - Search term in name or description
    * `:active` / `"active"` - Boolean filter for active status
    * `:order_by` - Order option (`:price_asc`, `:price_desc`, `:name`, default: `:newest`)
  """
  def list_products(params \\ %{}) do
    Product
    |> join(:inner, [p], c in assoc(p, :category), as: :category)
    |> filter_by_category(params)
    |> filter_by_search(params)
    |> filter_by_active(params)
    |> sort_products(params)
    |> preload([p, category: c], category: c)
    |> Repo.all()
  end

  defp filter_by_category(query, %{"category_id" => cat_id})
       when is_binary(cat_id) and cat_id != "" do
    where(query, [p], p.category_id == ^cat_id)
  end

  defp filter_by_category(query, %{category_id: cat_id}) when not is_nil(cat_id) do
    where(query, [p], p.category_id == ^cat_id)
  end

  defp filter_by_category(query, _), do: query

  defp filter_by_search(query, %{"search" => search}) when is_binary(search) and search != "" do
    search_term = "%#{search}%"
    where(query, [p], ilike(p.name, ^search_term) or ilike(p.description, ^search_term))
  end

  defp filter_by_search(query, %{search: search}) when is_binary(search) and search != "" do
    search_term = "%#{search}%"
    where(query, [p], ilike(p.name, ^search_term) or ilike(p.description, ^search_term))
  end

  defp filter_by_search(query, _), do: query

  defp filter_by_active(query, %{"active" => "true"}), do: where(query, [p], p.active == true)
  defp filter_by_active(query, %{"active" => "false"}), do: where(query, [p], p.active == false)
  defp filter_by_active(query, %{active: true}), do: where(query, [p], p.active == true)
  defp filter_by_active(query, %{active: false}), do: where(query, [p], p.active == false)
  defp filter_by_active(query, _), do: query

  defp sort_products(query, %{"sort" => "price_asc"}), do: order_by(query, [p], asc: p.price)
  defp sort_products(query, %{"sort" => "price_desc"}), do: order_by(query, [p], desc: p.price)
  defp sort_products(query, %{"sort" => "name"}), do: order_by(query, [p], asc: p.name)
  defp sort_products(query, _), do: order_by(query, [p], desc: p.inserted_at)

  @doc """
  Gets a single product.
  Raises `Ecto.NoResultsError` if the Product does not exist.
  """
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload(:category)
  end

  @doc """
  Gets a product by slug.
  Raises `Ecto.NoResultsError` if the Product does not exist.
  """
  def get_product_by_slug!(slug) when is_binary(slug) do
    Product
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(:category)
  end

  @doc """
  Gets a product by slug.
  Returns nil if the Product does not exist.
  """
  def get_product_by_slug(slug) when is_binary(slug) do
    Product
    |> Repo.get_by(slug: slug)
    |> Repo.preload(:category)
  end

  @doc """
  Creates a product.
  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.
  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.
  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.
  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  @doc """
  Updates stock for a product (used for orders).
  Ensures stock doesn't drop below 0.
  """
  def update_stock(%Product{} = product, quantity_change) when is_integer(quantity_change) do
    new_stock = product.stock + quantity_change

    if new_stock >= 0 do
      update_product(product, %{stock: new_stock})
    else
      {:error, :insufficient_stock}
    end
  end

  @doc """
  Gets related products from the same category.
  If not enough products in category, fills with other active products.
  """
  def get_related_products(%Product{} = product, limit \\ 4) do
    related =
      Product
      |> where([p], p.id != ^product.id)
      |> where([p], p.category_id == ^product.category_id)
      |> where([p], p.active == true)
      |> order_by([p], desc: p.inserted_at)
      |> limit(^limit)
      |> Repo.all()
      |> Repo.preload(:category)

    if length(related) < limit do
      fill_count = limit - length(related)

      fill =
        Product
        |> where([p], p.id != ^product.id)
        |> where([p], p.category_id != ^product.category_id)
        |> where([p], p.active == true)
        |> order_by([p], desc: p.inserted_at)
        |> limit(^fill_count)
        |> Repo.all()
        |> Repo.preload(:category)

      related ++ fill
    else
      related
    end
  end
end
