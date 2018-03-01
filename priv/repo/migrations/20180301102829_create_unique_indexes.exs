defmodule Gazoline.Repo.Migrations.CreateUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:restaurants, [:name, :address])
    create unique_index(:restaurants, :fsquare)
  end
end
