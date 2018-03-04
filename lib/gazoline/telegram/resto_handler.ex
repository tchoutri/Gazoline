defmodule Gazoline.Telegram.RestoHandler do

  use GenServer
  alias Gazoline.{Repo, Restaurant}
  import Gazoline.Geo, only: [get_resto: 1]
  require Logger
  import Gazoline.Telegram.Helpers


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

      update.message.text == "/start"              -> display_menus(update.message.chat.id)
      String.starts_with?(update.message.text, "/") -> parse_command(update.message.text, update.message.chat.id)

      update.message != nil -> parse(update.message.text, update.message.chat.id)
      true -> nil
    end
    {:noreply, state}
  end

  defp parse_command("/resto " <> string, id) do
    Logger.debug("Looking up #{string}")
    case get_resto(approx: string) do
      []      -> Nadia.send_message(id, "You're sure it's spelled like that? :/")
      results -> 
      Enum.each(results, fn resto ->
        {lat, long} = get_lat_long(resto.geom)
        Nadia.send_venue(id, lat, long, "#{resto.name} (#{resto.distance}m)" , resto.address, foursquare_id: resto.fsquare)
      end)
    end
  end

  defp parse_command(msg, id) do
    Logger.debug("Couldn't parse command: " <> msg)
    send_help(id)
  end


  defp parse_callback("/restaurant " <> venue_id, id, callback_id) do
    :ok = Nadia.answer_callback_query(callback_id, text: "~o~")
    case get_resto(venue_id: venue_id) do
      nil -> nil
      [resto] ->
        {lat, long} = get_lat_long(resto.geom)
        {:ok, _}    =
          Nadia.send_venue(id, lat, long, "#{resto.name} (#{resto.distance}m)" , resto.address, foursquare_id: resto.fsquare)
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


  @spec parse(String.t, integer) :: {:ok, Nadia.Model.Message.t} | {:error, Nadia.Model.Error.t | atom()}
  defp parse("/graw" <> _, id), do: Nadia.send_message(id, "Graw <3")
  defp parse(message, id) do
    with {:ok, [result|_]}     <- Botfuel.classify(message),
         {:ok, :display_menus} <- parse_answer(result) do
          display_menus(id)
    else
      {:ok, []} ->
        {:error, :nocommand}
      {:error, :wtf} ->
        Logger.warn "Wooops, I didn't understand that category…"
        {:error, :wtf}
      {:error, :nocommand} ->
        Logger.warn "No command was provided"
        {:error, :nocommand}
      {:ok, category} when is_binary(category) ->
        Logger.debug(inspect category)
        category
        |> build_category()
        |> send_category(id)
    end
  end

  @spec parse_answer(Botfuel.Classify.t) :: {:ok, String.t} | {:ok, :display_menus} | {:error, :wtf}
  @spec parse_answer(String.t)           :: {:ok, String.t} | {:ok, :display_menus} | {:error, :wtf}

  defp parse_answer(%{answer: answer}=_response), do: parse_answer(answer)
  defp parse_answer(answer) when is_binary(answer) do
    case Jason.decode!(answer) |> Map.get("result") do
      "choice" -> {:ok, :display_menus}
      category when category in ["Mexican", "Ethiopian", "Fast Food", "Basque", "Café / Bistro",
                                 "Italian", "Asian", "Middle Eastern", "Vegetarian / Vegan", "Hotel Bar",
                                 "Restaurant", "Fast Food", "Mexican", "Bakery", "Café / Bistro", "Coffee Shop"] -> {:ok, category}
      msg -> 
        Logger.debug("Couldn't understand #{inspect msg}")
        {:error, :wtf}
    end
  end
end
