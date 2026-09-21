defmodule Shop.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias Shop.Catalog.Category

  schema "products" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :price, :decimal
    field :stock, :integer, default: 0
    field :active, :boolean, default: true
    field :images, {:array, :string}, default: []

    belongs_to :category, Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :slug, :description, :price, :stock, :active, :images, :category_id])
    |> validate_required([:name, :price, :stock, :category_id])
    |> validate_number(:price, greater_than: 0, message: "debe ser mayor a cero")
    |> validate_number(:stock, greater_than_or_equal_to: 0, message: "no puede ser negativo")
    |> generate_slug()
    |> validate_required([:slug])
    |> validate_length(:name, min: 2, max: 200)
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:category_id)
  end

  defp generate_slug(changeset) do
    slug = get_change(changeset, :slug)
    name = get_change(changeset, :name)

    cond do
      is_binary(slug) and String.trim(slug) != "" ->
        put_change(changeset, :slug, Category.slugify(slug))

      is_binary(name) and String.trim(name) != "" and is_nil(get_field(changeset, :slug)) ->
        put_change(changeset, :slug, Category.slugify(name))

      true ->
        changeset
    end
  end
end
