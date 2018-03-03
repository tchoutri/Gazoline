defmodule Gazoline.TelegramTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Gazoline.Telegram.RestoHandler

  def categories, do: ["Fast Food", "Mexican", "Coffee Shop", "Burgers", "Snacks", "Ethiopian",
                "Thai", "Asian", "Café", "Middle Eastern", "Bakery", "Vietnamese",
                "Vegetarian / Vegan", "Doner", "Basque", "Hotel Bar", "French", "Bistro",
                "Italian", "Bar", "Chinese", "Restaurant", "Japanese", "Snack", "Real"]

  property "prepare_meta_category/3 Cannot accept any other category than Snack or Real" do
    check all cat <- member_of(categories) do
      assert Gazoline.Telegram.Helpers.prepare_meta_category(cat, 0, 0)
    end
  end
end
