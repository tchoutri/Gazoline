use Mix.Config

config :gazoline, Gazoline.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gazoline_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  types: Gazoline.PostgresTypes

config :logger,
  backends: [:console, {LoggerSyslogBackend, :syslog}]

config :logger, :syslog,
  app_id: :gazoline,
  path: "/dev/log"  
