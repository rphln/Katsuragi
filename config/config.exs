# Bot configuration.

import Config

config :logger,
  level: :info

config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

config :mojito,
  timeout: :infinity

config :katsuragi,
  pixiv_session_token: System.get_env("PIXIV_SESSION_TOKEN")

config :extwitter, :oauth,
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
  access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
  access_token_secret: System.get_env("TWITTER_ACCESS_TOKEN_SECRET")

config :katsuragi, Katsuragi.Scheduler,
  jobs: [
    {"20 19 * * *", {Katsuragi.Twitter, :send, []}}
  ]

if Mix.env() in [:dev, :test] do
  import_config "dev.secret.exs"
end
