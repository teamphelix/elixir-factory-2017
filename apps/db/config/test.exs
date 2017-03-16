use Mix.Config

config :db, Db.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "elixabot_test",
  username: "postgres",
  password: "postgres"
