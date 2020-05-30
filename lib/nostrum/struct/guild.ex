defmodule Nostrum.Struct.Guild do
  @moduledoc """
  Struct representing a Discord guild.
  """

  alias Nostrum.Struct.{Channel, Emoji}
  alias Nostrum.Struct.Guild.{Member, Role}
  alias Nostrum.Struct.Guild.Voice
  alias Nostrum.{Constants, Snowflake, Util}

  defstruct [
    :id,
    :name,
    :icon,
    :splash,
    :owner_id,
    :region,
    :afk_channel_id,
    :afk_timeout,
    :embed_enabled,
    :embed_channel_id,
    :verification_level,
    :default_message_notifications,
    :explicit_content_filter,
    :roles,
    :emojis,
    :features,
    :mfa_level,
    :application_id,
    :widget_enabled,
    :widget_channel_id,
    :system_channel_id,
    :joined_at,
    :large,
    :unavailable,
    :member_count,
    :voice_states,
    :members,
    :channels
  ]

  @typedoc "The guild's id"
  @type id :: Snowflake.t()

  @typedoc "The name of the guild."
  @type name :: String.t()

  @typedoc "The hash of the guild's icon"
  @type icon :: String.t() | nil

  @typedoc "The hash of the guild's splash"
  @type splash :: String.t() | nil

  @typedoc "The id of the guild owner"
  @type owner_id :: Snowflake.t()

  @typedoc "The id of the voice region"
  @type region :: String.t()

  @typedoc "The id of the guild's afk channel"
  @type afk_channel_id :: Snowflake.t() | nil

  @typedoc "The time someone must be afk before being moved"
  @type afk_timeout :: integer

  @typedoc "Whether the guild is emeddable"
  @type embed_enabled :: boolean | nil

  @typedoc "The id of the embedded channel"
  @type embed_channel_id :: Snowflake.t() | nil

  @typedoc "The level of verification"
  @type verification_level :: integer

  @typedoc """
  Default message notifications level.
  """
  @type default_message_notifications :: integer

  @typedoc """
  Explicit content filter level.
  """
  @type explicit_content_filter :: integer

  @typedoc "List of roles"
  @type roles :: %{required(Role.id()) => Role.t()}

  @typedoc "List of emojis"
  @type emojis :: [Emoji.t()]

  @typedoc "List of guild features"
  @type features :: [String.t()]

  @typedoc "Required MFA level of the guild"
  @type mfa_level :: integer

  @typedoc """
  Application id of the guild creator if it is bot created.
  """
  @type application_id :: Snowflake.t() | nil

  @typedoc """
  Whether or not the server widget is enabled.
  """
  @type widget_enabled :: boolean | nil

  @typedoc """
  The channel id for the server widget.
  """
  @type widget_channel_id :: Snowflake.t()

  @typedoc """
  The id of the channel to which system messages are sent.
  """
  @type system_channel_id :: Snowflake.t() | nil

  @typedoc "Date the bot user joined the guild"
  @type joined_at :: String.t() | nil

  @typedoc "Whether the guild is considered 'large'"
  @type large :: boolean | nil

  @typedoc "Whether the guild is avaliable"
  @type unavailable :: boolean | nil

  @typedoc "Total number of members in the guild"
  @type member_count :: integer | nil

  @typedoc "List of voice states as map of user IDs to states"
  @type voice_states :: %{required(User.id()) => Voice.State.t()} | nil

  @typedoc "List of members"
  @type members :: %{required(User.id()) => Member.t()} | nil

  @typedoc "List of channels"
  @type channels :: %{required(Channel.id()) => Channel.t()} | nil

  @typedoc """
  A `Nostrum.Struct.Guild` that is sent on user-specific rest endpoints.
  """
  @type user_guild :: %__MODULE__{
          id: id,
          name: name,
          icon: icon,
          splash: nil,
          owner_id: nil,
          region: nil,
          afk_channel_id: nil,
          afk_timeout: nil,
          embed_enabled: nil,
          embed_channel_id: nil,
          verification_level: nil,
          default_message_notifications: nil,
          explicit_content_filter: nil,
          roles: nil,
          emojis: nil,
          features: nil,
          mfa_level: nil,
          application_id: nil,
          widget_enabled: nil,
          widget_channel_id: nil,
          system_channel_id: nil,
          joined_at: nil,
          large: nil,
          unavailable: nil,
          member_count: nil,
          voice_states: nil,
          members: nil,
          channels: nil
        }

  @typedoc """
  A `Nostrum.Struct.Guild` that is sent on guild-specific rest endpoints.
  """
  @type rest_guild :: %__MODULE__{
          id: id,
          name: name,
          icon: icon,
          splash: splash,
          owner_id: owner_id,
          region: region,
          afk_channel_id: afk_channel_id,
          afk_timeout: afk_timeout,
          embed_enabled: embed_enabled,
          embed_channel_id: embed_channel_id,
          verification_level: verification_level,
          default_message_notifications: default_message_notifications,
          explicit_content_filter: explicit_content_filter,
          roles: roles,
          emojis: emojis,
          features: features,
          mfa_level: mfa_level,
          application_id: application_id,
          widget_enabled: widget_enabled,
          widget_channel_id: widget_channel_id,
          system_channel_id: system_channel_id,
          joined_at: nil,
          large: nil,
          unavailable: nil,
          member_count: nil,
          voice_states: nil,
          members: nil,
          channels: nil
        }

  @typedoc """
  A `Nostrum.Struct.Guild` that is unavailable.
  """
  @type unavailable_guild :: %__MODULE__{
          id: id,
          name: nil,
          icon: nil,
          splash: nil,
          owner_id: nil,
          region: nil,
          afk_channel_id: nil,
          afk_timeout: nil,
          embed_enabled: nil,
          embed_channel_id: nil,
          verification_level: nil,
          default_message_notifications: nil,
          explicit_content_filter: nil,
          roles: nil,
          emojis: nil,
          features: nil,
          mfa_level: nil,
          application_id: nil,
          widget_enabled: nil,
          widget_channel_id: nil,
          system_channel_id: nil,
          joined_at: nil,
          large: nil,
          unavailable: true,
          member_count: nil,
          voice_states: nil,
          members: nil,
          channels: nil
        }

  @typedoc """
  A `Nostrum.Struct.Guild` that is fully available.
  """
  @type available_guild :: %__MODULE__{
          id: id,
          name: name,
          icon: icon,
          splash: splash,
          owner_id: owner_id,
          region: region,
          afk_channel_id: afk_channel_id,
          afk_timeout: afk_timeout,
          embed_enabled: embed_enabled,
          embed_channel_id: embed_channel_id,
          verification_level: verification_level,
          default_message_notifications: default_message_notifications,
          explicit_content_filter: explicit_content_filter,
          roles: roles,
          emojis: emojis,
          features: features,
          mfa_level: mfa_level,
          application_id: application_id,
          widget_enabled: widget_enabled,
          widget_channel_id: widget_channel_id,
          system_channel_id: system_channel_id,
          joined_at: joined_at,
          large: large,
          unavailable: false,
          member_count: member_count,
          voice_states: voice_states,
          members: members,
          channels: channels
        }

  @type t ::
          available_guild
          | unavailable_guild
          | rest_guild
          | user_guild

  @doc ~S"""
  Returns the URL of a guild's icon, or `nil` if there is no icon.

  Supported image formats are PNG, JPEG, and WebP.

  ## Examples

  ```Elixir
  iex> guild = %Nostrum.Struct.Guild{icon: "86e39f7ae3307e811784e2ffd11a7310",
  ...>                               id: 41771983423143937}
  iex> Nostrum.Struct.Guild.icon_url(guild)
  "https://cdn.discordapp.com/icons/41771983423143937/86e39f7ae3307e811784e2ffd11a7310.webp"
  iex> Nostrum.Struct.Guild.icon_url(guild, "png")
  "https://cdn.discordapp.com/icons/41771983423143937/86e39f7ae3307e811784e2ffd11a7310.png"

  iex> guild = %Nostrum.Struct.Guild{icon: nil}
  iex> Nostrum.Struct.Guild.icon_url(guild)
  nil
  ```
  """
  @spec icon_url(t, String.t()) :: String.t() | nil
  def icon_url(guild, image_format \\ "webp")
  def icon_url(%__MODULE__{icon: nil}, _), do: nil

  def icon_url(%__MODULE__{icon: icon, id: id}, image_format),
    do: URI.encode(Constants.cdn_url() <> Constants.cdn_icon(id, icon, image_format))

  @doc ~S"""
  Returns the URL of a guild's splash, or `nil` if there is no splash.

  Supported image formats are PNG, JPEG, and WebP.

  ## Examples

  ```Elixir
  iex> guild = %Nostrum.Struct.Guild{splash: "86e39f7ae3307e811784e2ffd11a7310",
  ...>                               id: 41771983423143937}
  iex> Nostrum.Struct.Guild.splash_url(guild)
  "https://cdn.discordapp.com/splashes/41771983423143937/86e39f7ae3307e811784e2ffd11a7310.webp"
  iex> Nostrum.Struct.Guild.splash_url(guild, "png")
  "https://cdn.discordapp.com/splashes/41771983423143937/86e39f7ae3307e811784e2ffd11a7310.png"

  iex> guild = %Nostrum.Struct.Guild{splash: nil}
  iex> Nostrum.Struct.Guild.splash_url(guild)
  nil
  ```
  """
  @spec splash_url(t, String.t()) :: String.t() | nil
  def splash_url(guild, image_format \\ "webp")
  def splash_url(%__MODULE__{splash: nil}, _), do: nil

  def splash_url(%__MODULE__{splash: splash, id: id}, image_format),
    do: URI.encode(Constants.cdn_url() <> Constants.cdn_splash(id, splash, image_format))

  @doc false
  def p_encode do
    %__MODULE__{}
  end

  @doc false
  def to_struct(map) do
    new =
      map
      |> Map.new(fn {k, v} -> {Util.maybe_to_atom(k), v} end)
      |> Map.update(:id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:owner_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:afk_channel_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:roles, nil, &Util.cast(&1, {:index, [:id], {:struct, Role}}))
      |> Map.update(:emojis, nil, &Util.cast(&1, {:list, {:struct, Emoji}}))
      |> Map.update(:application_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:widget_channel_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:system_channel_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:members, nil, &Util.cast(&1, {:index, [:user, :id], {:struct, Member}}))
      |> Map.update(:channels, nil, &Util.cast(&1, {:index, [:id], {:struct, Channel}}))
      |> Map.update(
        :voice_states,
        nil,
        &Util.cast(&1, {:index, [:user_id], {:struct, Voice.State}})
      )

    struct(__MODULE__, new)
  end
end
