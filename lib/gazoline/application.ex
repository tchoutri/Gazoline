defmodule Gazoline.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    {app_id = System.get_env("BTFL_APPID"), app_key = System.get_env("BTFL_APPKEY")}

    bees_client = %Bees.Client{
      client_id:     System.get_env("FOURSQUARE_ID"),
      client_secret: System.get_env("FOURSQUARE_SECRET")
    }

    children = [
      {Gazoline.Geo, bees_client},
      Gazoline.Repo,
      Gazoline.EventHandler,
      Gazoline.Telegram.Poller,
      Gazoline.Telegram.RestoHandler,
      {Botfuel.Client, %{app_id: app_id, app_key: app_key}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gazoline.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
