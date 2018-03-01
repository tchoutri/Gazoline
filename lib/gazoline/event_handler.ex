defmodule Gazoline.EventHandler do

  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    Logger.info(IO.ANSI.green <> "[Gazoline] Starting EventHandler" <> IO.ANSI.reset())
    Registry.start_link(keys: :duplicate, name: __MODULE__)
    {:ok, :ok}
  end

  def broadcast(topic, message) do
    Registry.dispatch(__MODULE__, topic, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, {topic, message})
    end)
  end

  def subscribe(topic) do
    Registry.register(__MODULE__, topic, [])
  end
end
