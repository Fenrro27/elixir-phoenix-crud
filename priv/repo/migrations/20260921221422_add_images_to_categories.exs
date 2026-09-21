defmodule Shop.Repo.Migrations.AddImagesToCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :images, {:array, :string}, default: []
    end
  end
end
