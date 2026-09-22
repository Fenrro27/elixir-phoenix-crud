defmodule ShopWeb.ProductHTML do
  use ShopWeb, :html

  embed_templates "product_html/*"

  @doc """
  Renders a product form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :categories, :list, default: []

  def product_form(assigns)

  @doc """
  Formats a decimal price to currency display.
  """
  def format_price(nil), do: "$0.00"

  def format_price(%Decimal{} = price) do
    "$" <> Decimal.to_string(price, :normal)
  end

  def format_price(amount) when is_binary(amount), do: "$" <> amount

  def format_price(amount) when is_number(amount),
    do: :io_lib.format("$~.2f", [amount * 1.0]) |> to_string()

  @doc """
  Renders stock status badge with appropriate styling.
  """
  def stock_badge(assigns) do
    ~H"""
    <%= if @stock > 10 do %>
      <span class="inline-flex items-center rounded-md bg-emerald-50 px-2 py-1 text-xs font-medium text-emerald-700 ring-1 ring-inset ring-emerald-600/20">
        En stock ({@stock})
      </span>
    <% else %>
      <%= if @stock > 0 do %>
        <span class="inline-flex items-center rounded-md bg-amber-50 px-2 py-1 text-xs font-medium text-amber-800 ring-1 ring-inset ring-amber-600/20">
          Últimas {@stock} u.
        </span>
      <% else %>
        <span class="inline-flex items-center rounded-md bg-rose-50 px-2 py-1 text-xs font-medium text-rose-700 ring-1 ring-inset ring-rose-600/20">
          Agotado
        </span>
      <% end %>
    <% end %>
    """
  end
end
