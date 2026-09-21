defmodule ShopWeb.CategoryHTML do
  use ShopWeb, :html

  embed_templates "category_html/*"

  @doc """
  Renders a category form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :categories, :list, default: []

  def category_form(assigns)
end
