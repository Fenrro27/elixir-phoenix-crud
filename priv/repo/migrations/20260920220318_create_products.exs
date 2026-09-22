defmodule Shop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :stock, :integer, default: 0, null: false
      add :active, :boolean, default: true, null: false
      add :images, {:array, :string}, default: []
      add :category_id, references(:categories, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:slug])
    create index(:products, [:category_id])
  end
end
