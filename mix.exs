defmodule Gazoline.MixProject do
  use Mix.Project

  def project do
    [
      app: :gazoline,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gazoline.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bees, "~> 0.3"},
      {:botfuel, github: "tchoutri/botfuel-elixir-sdk"},
      {:distillery, "~> 1.5.2"},
      {:ecto, "~> 2.2"},
      {:geo, "~> 2.1"},
      {:geo_postgis, "~> 1.1"},
      {:logger_syslog_backend, "~> 1.0.0"},
      {:nadia, "~> 0.4"},
      {:postgrex, "~> 0.13"},
      {:stream_data, "~> 0.4.1", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],# "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.drop", "ecto.create --quiet", "ecto.migrate", "run test/seeds.exs", "test"]
    ]
  end

end
