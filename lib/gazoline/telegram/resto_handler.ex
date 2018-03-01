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
      update.callback_query != nil -> parse_callback(update.callback_query.data, update.callback_query.message.chat.id)
      update.message != nil -> parse(update.message.text, update.message.chat.id)
      true -> nil
    end
    {:noreply, state}
  end


  defp parse_callback("/restaurant " <> resto_id, id) do
    case Repo.get(Restaurant, resto_id) do
      nil -> nil
      %Restaurant{}=resto ->
        :ok         = Nadia.send_chat_action(id, "typing")
        {lat, long} = resto.geom.coordinates
        {:ok, _}    = Nadia.send_venue(id, lat, long, resto.name, resto.address, foursquare_id: resto.fsquare)
    end
  end

  defp parse_callback("/foodtype " <> foodtype, id) do
    closests  = Repo.all(Geo.nth_closests(5, foodtype)) |> Enum.map(fn resto -> %{id: resto.id, text: resto.name <> " — " <> resto.address} end)
    keyboards = closests |> Enum.chunk_every(1) |> Enum.map(fn chunk -> Enum.map(chunk, fn resto -> %{callback_data: "/restaurant #{resto.id}", text: resto.text} end) end)
    {:ok, _} = Nadia.send_message(id, "Here are the restaurants for your pick: ", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards})
  end


  defp parse("/graw" <> _, id) do
    Nadia.send_message(id, "Graw <3")
  end

  defp parse(message, id) do
    case Botfuel.classify(message) do
      {:ok, %Botfuel.Classify{answer: anwser}} ->
        categories = ["Fast Food", "Mexican","Ethiopian", "Bakery", "Basque",
                      "Bistro / Café", "Italian", "Coffee Shop", "Asian", "Middle Eastern",
                      "Vegetarian / Vegan", "Hotel Bar", "Restaurant"]

        keyboards = categories |> Enum.chunk_every(1) |> Enum.map(fn chunk -> Enum.map(chunk, fn cat -> %{callback_data: "/foodtype #{cat}", text: cat} end) end)
        Nadia.send_message id, "Your choice?", reply_markup: %Nadia.Model.InlineKeyboardMarkup{inline_keyboard: keyboards}
      {:error, error} ->
        Logger.error "Nah something went wrong with the platform"
    end
  end
end
