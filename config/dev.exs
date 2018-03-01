use Mix.Config

config :gazoline, Gazoline.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gazoline_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  types: Gazoline.PostgresTypes
