defmodule Shop.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :parent_id, references(:categories, on_delete: :nilify_all)
      add :position, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:slug])
    create index(:categories, [:parent_id])
  end
end
