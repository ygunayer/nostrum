defmodule Nostrum.Shard.Dispatch do
  @moduledoc false

  alias Nostrum.Cache.{GuildCache, ChannelCache, PresenceCache, UserCache}
  alias Nostrum.Cache.Guild.GuildServer
  alias Nostrum.Cache.Me
  alias Nostrum.Shard.Session
  alias Nostrum.Struct.Event.{MessageDelete, MessageDeleteBulk}
  alias Nostrum.Struct.{Guild, Message, User}
  alias Nostrum.Struct.Guild.UnavailableGuild
  alias Nostrum.Util

  require Logger

  @large_threshold 250

  def handle({payload, state}) do
    if Application.get_env(:nostrum, :log_full_events),
      do: Logger.debug(inspect(payload.d, pretty: true))

    payload.t
    |> handle_event(payload.d, state)
    |> format_event
  end

  defp format_event(events) when is_list(events),
    do: for(event <- events, do: format_event(event))

  # Handles the case of not finding users in the user cache
  defp format_event({_name, :noop, _state}), do: :noop
  defp format_event({_name, event_info, _state} = event) when is_tuple(event_info), do: event
  defp format_event({name, event_info, state}), do: {name, event_info, state}
  defp format_event(:noop), do: :noop

  defp check_new_or_unavailable(guild_id) do
    case :ets.lookup(:unavailable_guilds, guild_id) do
      [] -> :GUILD_CREATE
      [_] -> :GUILD_AVAILABLE
    end
  end

  def handle_event(:CHANNEL_CREATE = event, %{type: 1} = p, state) do
    {event, ChannelCache.create(p), state}
  end

  def handle_event(:CHANNEL_CREATE = event, %{type: t} = p, state) when t in [0, 2] do
    :ets.insert(:channel_guild_map, {p.id, p.guild_id})
    {event, GuildServer.channel_create(p.guild_id, p), state}
  end

  # Ignore group channels
  def handle_event(:CHANNEL_CREATE, _p, _state) do
    :noop
  end

  def handle_event(:CHANNEL_DELETE = event, %{type: 1} = p, state) do
    {event, ChannelCache.delete(p), state}
  end

  def handle_event(:CHANNEL_DELETE = event, %{type: t} = p, state) when t in [0, 2] do
    :ets.delete(:channel_guild_map, p.id)
    {event, GuildServer.channel_delete(p.guild_id, p.id), state}
  end

  def handle_event(:CHANNEL_UPDATE = event, p, state) do
    {event, GuildServer.channel_update(p.guild_id, p), state}
  end

  def handle_event(:CHANNEL_DELETE, _p, _state) do
    # Ignore group channels
    :noop
  end

  def handle_event(:CHANNEL_PINS_ACK = event, p, state), do: {event, p, state}

  def handle_event(:CHANNEL_PINS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:GUILD_BAN_ADD = event, p, state), do: {event, {p.guild_id, p}, state}

  def handle_event(:GUILD_BAN_REMOVE = event, p, state), do: {event, {p.guild_id, p}, state}

  def handle_event(:GUILD_CREATE, %{unavailable: true} = guild, state) do
    :ets.insert(:unavailable_guilds, {guild.id, guild})
    {:GUILD_UNAVAILABLE, UnavailableGuild.to_struct(guild), state}
  end

  def handle_event(:GUILD_CREATE, p, state) do
    # Ensures every channel will have an associated guild_id
    channels_with_guild_id =
      p.channels
      |> Enum.map(fn channel -> Map.put(channel, :guild_id, p.id) end)

    guild = %{p | channels: channels_with_guild_id}

    guild.members
    |> Enum.each(fn member -> UserCache.create(member.user) end)

    :ets.insert(:guild_shard_map, {guild.id, state.shard_num})

    Enum.each(guild.channels, fn channel ->
      :ets.insert(:channel_guild_map, {channel.id, guild.id})
    end)

    if guild.member_count >= @large_threshold and
         Application.get_env(:nostrum, :request_guild_members, false) do
      Session.request_guild_members(state.conn_pid, guild.id)
    end

    {presences, guild} = Map.pop(guild, :presences, [])
    PresenceCache.bulk_create(guild.id, presences)

    guild = Util.cast(guild, {:struct, Guild})

    case GuildServer.create(guild) do
      {:error, reason} ->
        Logger.warn("Failed to create new guild process: #{inspect(reason)}")
        :noop

      {:ok, g} ->
        {check_new_or_unavailable(g.id), {g}, state}
    end
  end

  def handle_event(:GUILD_UPDATE = event, p, state), do: {event, GuildServer.update(p), state}

  def handle_event(:GUILD_DELETE = event, p, state) do
    :ets.delete(:guild_shard_map, p.id)
    {event, {GuildServer.delete(p.id), Map.get(p, :unavailable, false)}, state}
  end

  def handle_event(:GUILD_EMOJIS_UPDATE = event, p, state),
    do: {event, GuildServer.emoji_update(p.guild_id, p.emojis), state}

  def handle_event(:GUILD_INTEGRATIONS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:GUILD_MEMBER_ADD = event, p, state) do
    UserCache.create(p.user)
    {event, GuildServer.member_add(p.guild_id, p), state}
  end

  def handle_event(:GUILD_MEMBERS_CHUNK = event, p, state) do
    UserCache.bulk_create(p.members)
    GuildServer.member_chunk(p.guild_id, p.members)

    {event, p, state}
  end

  def handle_event(:GUILD_MEMBER_REMOVE = event, p, state),
    do: {event, GuildServer.member_remove(p.guild_id, p.user), state}

  def handle_event(:GUILD_MEMBER_UPDATE = event, p, state),
    do: {event, GuildServer.member_update(p.guild_id, p), state}

  def handle_event(:GUILD_ROLE_CREATE = event, p, state),
    do: {event, GuildServer.role_create(p.guild_id, p.role), state}

  def handle_event(:GUILD_ROLE_DELETE = event, p, state),
    do: {event, GuildServer.role_delete(p.guild_id, p.role_id), state}

  def handle_event(:GUILD_ROLE_UPDATE = event, p, state),
    do: {event, GuildServer.role_update(p.guild_id, p.role), state}

  def handle_event(:MESSAGE_CREATE = event, p, state), do: {event, Message.to_struct(p), state}

  def handle_event(:MESSAGE_DELETE = event, p, state),
    do: {event, struct(MessageDelete, p), state}

  def handle_event(:MESSAGE_DELETE_BULK = event, p, state),
    do: {event, struct(MessageDeleteBulk, p), state}

  def handle_event(:MESSAGE_UPDATE = event, p, state), do: {event, Message.to_struct(p), state}

  def handle_event(:MESSAGE_REACTION_ADD = event, p, state), do: {event, p, state}

  def handle_event(:MESSAGE_REACTION_REMOVE = event, p, state), do: {event, p, state}

  def handle_event(:MESSAGE_REACTION_REMOVE_ALL = event, p, state), do: {event, p, state}

  def handle_event(:MESSAGE_REACTION_REMOVE_EMOJI = event, p, state), do: {event, p, state}

  def handle_event(:MESSAGE_ACK = event, p, state), do: {event, p, state}

  def handle_event(:PRESENCE_UPDATE = event, p, state) do
    [
      {event, PresenceCache.update(p), state}
      | [handle_event(:USER_UPDATE, p.user, state)]
    ]
  end

  def handle_event(:READY = event, p, state) do
    p.private_channels
    |> Enum.each(fn dm_channel -> ChannelCache.create(dm_channel) end)

    ready_guilds =
      p.guilds
      |> Enum.map(fn guild -> handle_event(:GUILD_CREATE, guild, state) end)

    current_user = Util.cast(p.user, {:struct, User})
    Me.put(current_user)

    [{event, p, state}] ++ ready_guilds
  end

  def handle_event(:RESUMED = event, p, state), do: {event, p, state}

  def handle_event(:TYPING_START = event, p, state), do: {event, p, state}

  def handle_event(:USER_SETTINGS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:USER_UPDATE = event, p, state) do
    if Me.get().id === p.id do
      Me.update(p)
    end

    {event, UserCache.update(p), state}
  end

  def handle_event(:VOICE_STATE_UPDATE = event, p, state) do
    # Discord only sends guild_id when a user leaves a voice channel, in which case channel_id is null
    # in other cases, guild_id instead is null, so we have to figure the corresponding guild_id based on channel_id
    case p.channel_id do
      nil ->
        GuildServer.voice_state_update(p.guild_id, nil, p)

      id ->
        case ChannelCache.get(id) do
          {:ok, channel} ->
            GuildServer.voice_state_update(channel.guild_id, channel.id, p)

          _ ->
            Logger.warn("Failed to handle voice state update because channel #{id} was not found")
        end
    end

    {event, p, state}
  end

  def handle_event(:VOICE_SERVER_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(:WEBHOOKS_UPDATE = event, p, state), do: {event, p, state}

  def handle_event(event, p, state) do
    Logger.warn("UNHANDLED GATEWAY DISPATCH EVENT TYPE: #{event}, #{inspect(p)}")
    {event, p, state}
  end
end
