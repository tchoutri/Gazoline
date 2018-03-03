use Mix.Config

config :gazoline, Gazoline.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gazoline_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  types: Gazoline.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox
