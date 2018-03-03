defmodule Gazoline.Telegram.Helpers do

  alias Gazoline.{Geo,Repo}
  require Logger

  def display_menus(id) do
    Nadia.send_message(id, "Cool, what do you want?",
                       reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[%{text: "Just snacking", callback_data: "/mealtype Snack"},
                                                                                          %{text: "A real meal.",  callback_data: "/mealtype Real"}]]})
  end

  ## Meta-categories ##
  @spec send_meta_category(String.t, integer, integer()) :: {:ok, Nadia.Model.Message.t()} | {:error, :wrong_category |  Nadia.Model.Error.t}
  def send_meta_category("Snack", id, callback_id) do
    %{id: id, callback_id: callback_id, keyboards: keyboards} = prepare_meta_category("Snack", id, callback_id)
    :ok = Nadia.answer_callback_query(callback_id, text: ":-D")
    Nadia.send_message id, "Here you are!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end

  def send_meta_category("Real", id, callback_id) do
    %{id: id, callback_id: callback_id, keyboards: keyboards} = prepare_meta_category("Real", id, callback_id)
    :ok = Nadia.answer_callback_query(callback_id, text: "\o/")
    Nadia.send_message id, "You're all set!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end


  @spec prepare_meta_category(String.t, integer, integer) :: map()
  def prepare_meta_category(meta_category, id, callback_id) when meta_category in ["Snack", "Real"] do
    keyboards = build_meta_category(meta_category)
    %{id: id, callback_id: callback_id, keyboards: keyboards}
  end

  def prepare_meta_category(mcat, _, _) do
    Logger.error "[Telegram] Bad meta-category #{inspect mcat}!"
    {:error, :wrong_category}
  end

  def build_meta_category("Real") do
    ["Mexican", "Ethiopian", "Fast Food", "Basque", "Café / Bistro",
     "Italian", "Asian", "Middle Eastern", "Vegetarian / Vegan", "Hotel Bar", "Restaurant"]
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end)
    end)
  end

  def build_meta_category("Snack") do
    ["Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"]
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end)
    end)
  end


  ## Single category ##

  def build_category(category) when is_binary(category) do
    5
    |> Geo.nth_closests(category)
    |> Repo.all
    |> Enum.map(fn resto -> %{fsquare: resto.fsquare, text: resto.name <> " — " <> resto.address} end)
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn resto -> %{callback_data: "/restaurant #{resto.fsquare}", text: resto.text} end)
    end)
  end

  @spec send_category([map()], integer) :: {:ok, Nadia.Model.Message.t} | {:error, Nadia.Model.Error.t}
  def send_category(keyboards, id) do
    Nadia.send_message(id, "Check out those!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards})
  end
end
