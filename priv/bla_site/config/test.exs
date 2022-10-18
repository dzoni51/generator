import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bla_site, BlaSiteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kcbwRx2YvgFQraVnAPikp/DuR9Hqnb826qzG31cRo/ayWzJy0aJPoWV9Z9I17ri8",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
