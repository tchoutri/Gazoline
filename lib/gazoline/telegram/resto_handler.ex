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
      update.callback_query != nil -> parse_callback(update.callback_query.data, update.callback_query.message.chat.id, update.callback_query.id)
      update.message.text == "/start" -> display_menus(update.message.chat.id)
      update.message != nil -> parse(update.message.text, update.message.chat.id)
      true -> nil
    end
    {:noreply, state}
  end


  defp parse_callback("/restaurant " <> venue_id, id, callback_id) do
    :ok = Nadia.answer_callback_query(callback_id, text: "~o~")
    case Repo.get_by(Restaurant, fsquare: venue_id) do
      nil -> nil
      %Restaurant{}=resto ->
        {lat, long} = resto.geom.coordinates
        {:ok, _}    = Nadia.send_venue(id, lat, long, resto.name, resto.address, foursquare_id: resto.fsquare)
    end
  end

  defp parse_callback("/category " <> category, id, callback_id) do
    Logger.debug("\"#{category}\"")
    case build_category(category) do
      [] ->
        Nadia.send_message(id, "Sorry, no restaurants for this category :/")
      result  ->
        :ok = Nadia.answer_callback_query(callback_id, text: ";)")
        send_category(result, id)
    end
  end

  defp parse_callback("/mealtype " <> type, id, callback_id) do
    send_meta_category(type, id, callback_id)
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
        category
        |> build_category()
        |> send_category(id)
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
                                 "Italian", "Asian", "Middle Eastern", "Vegetarian / Vegan", "Hotel Bar",
                                 "Restaurant", "Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"] -> {:ok, category}
      msg -> 
        Logger.debug("Couldn't understand #{inspect msg}")
        {:error, :wtf}
    end
  end

  defp display_menus(id) do
    {:ok, _} = Nadia.send_message(id, "Cool, what do you want?",
                                reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: [[%{text: "Just snacking", callback_data: "/mealtype Snack"},
                                                                                                  %{text: "A real meal.",  callback_data: "/mealtype Real"}]]})
  end

  ## Meta-categories ##
  
  defp send_meta_category("Snack", id, callback_id) do
    %{id: id, callback_id: callback_id, keyboards: keyboards} = prepare_meta_category("Snack", id, callback_id)
    :ok = Nadia.answer_callback_query(callback_id, text: ":-D")
    Nadia.send_message id, "Here you are!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end

  defp send_meta_category("Real", id, callback_id) do
    %{id: id, callback_id: callback_id, keyboards: keyboards} = prepare_meta_category("Real", id, callback_id)
    :ok = Nadia.answer_callback_query(callback_id, text: "\o/")
    Nadia.send_message id, "You're all set!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
  end

  defp prepare_meta_category(meta_category, id, callback_id) when meta_category in ["Snack", "Real"] do
    keyboards = build_meta_category(meta_category)
    %{id: id, callback_id: callback_id, keyboards: keyboards}
  end

  defp build_meta_category("Real") do
    ["Mexican", "Ethiopian", "Fast Food", "Basque", "Café / Bistro",
     "Italian", "Asian", "Middle Eastern", "Vegetarian / Vegan", "Hotel Bar", "Restaurant"]
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end)
    end)
  end

  defp build_meta_category("Snack") do
    ["Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"]
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn cat -> %{callback_data: "/category #{cat}", text: cat} end)
    end)
  end

  ## Single category ##

  defp build_category(category) when is_binary(category) do
    5
    |> Geo.nth_closests(category)
    |> Repo.all
    |> Enum.map(fn resto -> %{fsquare: resto.fsquare, text: resto.name <> " — " <> resto.address} end)
    |> Enum.chunk_every(1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn resto -> %{callback_data: "/restaurant #{resto.fsquare}", text: resto.text} end)
    end)
  end

  defp send_category(keyboards, id) do
    {:ok, _} = Nadia.send_message(id, "Check out those!", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards})
  end
end
