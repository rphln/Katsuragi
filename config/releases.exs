# Runtime configuration for releases.

import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :katsuragi,
  pixiv_session_token: System.get_env("PIXIV_SESSION_TOKEN")
