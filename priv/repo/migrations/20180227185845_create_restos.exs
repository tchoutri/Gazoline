defmodule Gazoline.Repo.Migrations.CreateRestos do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis", "DROP EXTENSION IF EXISTS postgis"
    create table(:restaurants) do
      add :name,     :string, null: false
      add :address,  :string
      add :category, :string
      add :geom,     :geography
      add :fsquare,  :string

      timestamps()
    end
  end
end
