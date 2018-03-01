defmodule Gazoline.Dish do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Gazoline.Restaurant

  schema "dishes" do
    field :name, :string
    field :price, :integer
    field :tags, {:array, :string}
    belongs_to :restaurant, Restaurant
    
    timestamps()
  end

  def changeset(%Dish{}=resto, attrs) do
    resto
    |> cast(attrs, [:name, :price, :tags])
    |> validate_required([:name, :price, :tags])
  end
end
