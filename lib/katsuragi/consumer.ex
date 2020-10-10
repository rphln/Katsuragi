defmodule Katsuragi.Consumer do
  @moduledoc """
  Discord event handler.
  """

  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Consumer
  alias Nostrum.Struct.User

  alias Katsuragi.Routes

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def handle_event({:MESSAGE_CREATE, message, _ws_state}) do
    unless message.author.bot do
      Routes.dispatch(message)
    end
  end

  def handle_event({:READY, _data, _ws_state}) do
    Api.update_status(:online, "Last restart at #{NaiveDateTime.utc_now()}")
  end

  @greet [206_597_768_310_030_337]
  @events [:GUILD_MEMBER_ADD, :GUILD_MEMBER_REMOVE, :GUILD_BAN_ADD]

  def handle_event({event, {guild_id, member}, _ws_state})
      when guild_id in @greet and event in @events do
    guild = GuildCache.get!(guild_id)
    mention = User.mention(member.user)

    message =
      case event do
        :GUILD_MEMBER_ADD ->
          "Welcome #{mention}! Please read our rules in <#649791269052088330>."

        :GUILD_MEMBER_REMOVE ->
          "#{mention} (`#{member.user.username}##{member.user.discriminator}`) has left!"

        :GUILD_BAN_ADD ->
          "#{mention} (`#{member.user.username}##{member.user.discriminator}`) has been banned!"
      end

    Api.create_message(guild.system_channel_id, message)
  end

  def handle_event(_) do
    nil
  end
end
