defmodule Shop.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :position, :integer, default: 0

    belongs_to :parent, Shop.Catalog.Category
    has_many :children, Shop.Catalog.Category, foreign_key: :parent_id
    has_many :products, Shop.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description, :parent_id, :position])
    |> validate_required([:name])
    |> generate_slug()
    |> validate_required([:slug])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:parent_id)
  end

  defp generate_slug(changeset) do
    slug = get_change(changeset, :slug)
    name = get_change(changeset, :name)

    cond do
      is_binary(slug) and String.trim(slug) != "" ->
        put_change(changeset, :slug, slugify(slug))

      is_binary(name) and String.trim(name) != "" and is_nil(get_field(changeset, :slug)) ->
        put_change(changeset, :slug, slugify(name))

      true ->
        changeset
    end
  end

  def slugify(nil), do: ""

  def slugify(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s_-]+/, "-")
    |> String.trim("-")
  end
end
