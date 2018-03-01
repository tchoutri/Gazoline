defmodule Gazoline.Repo.Migrations.CreateDish do
  use Ecto.Migration

  def change do
    create table(:dishes) do
      add :name, :string
      add :price, :integer
      add :restaurant_id, references("restaurants"), null: false
      add :tags, {:array, :string}

      timestamps()
    end
  end
end
