# Runtime configuration for releases.

import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :katsuragi,
  pixiv_username: System.get_env("PIXIV_USERNAME"),
  pixiv_password: System.get_env("PIXIV_PASSWORD")
