defmodule Gazoline.Telegram.Poller do

  alias Nadia.Model.Update
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(offset) do
    Logger.info(IO.ANSI.green <> "[Telegram] Starting Poller" <> IO.ANSI.reset())
    schedule_polling()
    {:ok, offset}
  end

  def handle_info(:poll, offset) do
    new_offset = poll(offset)
    schedule_polling()

    {:noreply, new_offset + 1}
  end

  defp schedule_polling do
    Process.send_after(self(), :poll, 100)
  end

  @spec poll(integer()) :: integer()
  def poll(offset) do
    offset
    |> updates
    |> process_messages
  end

  @spec updates(integer()) :: [Update.t]
  defp updates(offset) do
    case Nadia.get_updates([offset: offset]) do
      {:ok, new_updates} -> new_updates
      _                  -> []
    end
  end

  @spec process_messages([Update.t]) :: integer()
  defp process_messages(updates) do
    updates
    |> Enum.reduce(0, fn(%Update{update_id: update_id} = update, _acc) ->
      Gazoline.EventHandler.broadcast(:tg_update, update)
      update_id
    end)
  end
end
