defmodule ShopWeb.CategoryController do
  use ShopWeb, :controller

  alias Shop.Catalog
  alias Shop.Catalog.Category

  def index(conn, _params) do
    categories = Catalog.list_categories()
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    changeset = Catalog.change_category(%Category{})
    categories = Catalog.category_select_options()
    render(conn, :new, changeset: changeset, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    case Catalog.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Categoría creada con éxito.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Catalog.category_select_options()
        render(conn, :new, changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)
    changeset = Catalog.change_category(category)

    categories =
      Catalog.category_select_options()
      |> Enum.reject(fn {_name, cat_id} -> cat_id == category.id end)

    render(conn, :edit, category: category, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Catalog.get_category!(id)

    case Catalog.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Categoría actualizada con éxito.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories =
          Catalog.category_select_options()
          |> Enum.reject(fn {_name, cat_id} -> cat_id == category.id end)

        render(conn, :edit, category: category, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Catalog.get_category!(id)

    case Catalog.delete_category(category) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Categoría eliminada con éxito.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(
          :error,
          "No se puede eliminar la categoría porque contiene productos asociados."
        )
        |> redirect(to: ~p"/categories/#{category}")
    end
  end
end
