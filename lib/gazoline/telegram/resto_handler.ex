defmodule Gazoline.Telegram.RestoHandler do

  use GenServer
  alias Gazoline.{Repo, Geo, Restaurant}
  require Logger


  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    Gazoline.EventHandler.subscribe(:tg_update)
    {:ok, :ok}
  end

  def handle_cast({:tg_update, update}, state) do
    cond do
      update.edited_message != nil -> parse(update.edited_message.text, update.message.chat.id)
      update.callback_query != nil -> parse_callback(update.callback_query.data, update.callback_query.message.chat.id)
      update.message.text == "/start" -> display_menus(update.message.chat.id)
      update.message != nil -> parse(update.message.text, update.message.chat.id)
      true -> nil
    end
    {:noreply, state}
  end


  defp parse_callback("/restaurant " <> venue_id, id) do
    case Repo.get_by(Restaurant, fsquare: venue_id) do
      nil -> nil
      %Restaurant{}=resto ->
        :ok         = Nadia.send_chat_action(id, "typing")
        {lat, long} = resto.geom.coordinates
        {:ok, _}    = Nadia.send_venue(id, lat, long, resto.name, resto.address, foursquare_id: resto.fsquare)
    end
  end

  defp parse_callback("/category " <> category, id) do
    closests  = Repo.all(Geo.nth_closests(5, category)) |> Enum.map(fn resto -> %{fsquare: resto.fsquare, text: resto.name <> " — " <> resto.address} end)
    keyboards = closests |> Enum.chunk_every(1) |> Enum.map(fn chunk -> Enum.map(chunk, fn resto -> %{callback_data: "/restaurant #{resto.fsquare}", text: resto.text} end) end)
    case keyboards do
      [] ->
        Nadia.send_message(id, "Sorry, no restaurants for this category")
      _  ->
        {:ok, _} = Nadia.send_message(id, "Check out those", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards})
    end
  end


  defp parse_callback("/mealtype " <> type, id) do
    send_categories(type, id)
  end

  defp parse("/graw" <> _, id) do
    Nadia.send_message(id, "Graw <3")
  end

  defp parse(message, id) do
    result = case Botfuel.classify(message) do
              [] ->
                {:error, :nocommand}
              results ->
                hd(results) |> Map.get(:answer) |> parse_a
            end

    case result do
      {:ok, :display_menus} ->
        display_menus(id)
      {:ok, category} when is_binary(category) ->
        Logger.debug(inspect category)
        parse_callback("/category " <> category, id)
      {:error, :wtf} ->
        Logger.warn "Wooops, I didn't understand."
      {:error, :nocommand} ->
        Logger.warn "Wooops, I didn't understand."
      error -> Logger.error "Unmatched error: " <> (inspect error)
    end
  end

  defp parse_a(json) do

    case Jason.decode!(json) |> Map.get("result") do
      "choice" -> {:ok, :display_menus}
      category when category in ["Mexican", "Ethiopian", "Fast Food", "Basque", "Café / Bistro",
                                 "Italian", "Asian", "Middle-Eastern", "Vegetarian / Vegan", "Hotel Bar",
                                 "Restaurant", "Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"] -> {:ok, category}
      _ -> {:error, :wtf}
    end
  end

  defp display_menus(id) do
    {:ok, _} = Nadia.send_message(id, "Cool, what do you want?",
                                reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[%{text: "Just snacking", callback_data: "/mealtype Snack"},
                                                                                                  %{text: "A real meal.",  callback_data: "/mealtype Real"}]]})
  end

  defp send_categories("Snack", id) do
    categories = ["Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"]
    keyboards = categories |> Enum.chunk_every(1) |> Enum.map(fn chunk -> Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end) end)
    Nadia.answer_callback_query(id)
    Nadia.send_message id, "Here you are", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end

  defp send_categories("Real", id) do
    categories = ["Mexican", "Ethiopian", "Fast Food", "Basque", "Café / Bistro",
                  "Italian", "Asian", "Middle-Eastern", "Vegetarian / Vegan", "Hotel Bar",
                  "Restaurant"]
    keyboards = categories |> Enum.chunk_every(1) |> Enum.map(fn chunk -> Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end) end)
    Nadia.answer_callback_query(id)
    Nadia.send_message id, "You're all set!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end

end
