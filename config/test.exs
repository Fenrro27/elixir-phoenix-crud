import Config

# Configure your database
config :shop, Shop.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "shop_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shop, ShopWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WyogydMcg7HycBqcMAdZ/MdjXSw0J+SZ2wPAVKWItzcv7e15o2KWtAidDT0hmrhW",
  server: false

# In test we don't send emails
config :shop, Shop.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
