use Mix.Config

config :gazoline, Gazoline.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gazoline_prod",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  types: Gazoline.PostgresTypes

config :logger, :syslog,
  app_id: :gazoline,
  path: "/dev/klog"  
