# Bot configuration.

import Config

config :logger,
  level: :info

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :katsuragi,
  pixiv_username: System.get_env("PIXIV_USERNAME"),
  pixiv_password: System.get_env("PIXIV_PASSWORD")

if Mix.env() in [:dev, :test] do
  import_config "dev.secret.exs"
end
