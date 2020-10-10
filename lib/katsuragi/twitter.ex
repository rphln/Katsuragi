defmodule Katsuragi.Twitter do
  alias Nostrum.Api

  @limit 8192
  @channel_id 762_818_878_216_601_611

  def send() do
    message = Api.get_channel_messages!(@channel_id, @limit) |> Enum.random()
    ExTwitter.update(message.content)
  end
end
