defmodule Gazoline.Restaurant do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Gazoline.Dish

  schema "restaurants" do
    field :address,  :string
    field :category, :string
    field :geom,     Geo.Geometry
    field :name,     :string
    field :fsquare,  :string
    has_many :dishes, Dish

    timestamps()
  end

  def changeset(%Restaurant{}=resto, attrs) do
    resto
    |> cast(attrs, [:name, :address, :geom, :category])
    |> validate_required([:name, :address, :geom, :category])
    |> unique_constraint(:name, name: :restaurants_name_address_index)
    |> unique_constraint(:fsquare)
  end
end
