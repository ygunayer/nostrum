defmodule Nostrum.Struct.Guild.Voice.State do
  @moduledoc ~S"""
  Struct representing a Discord voice state.
  """

  alias Nostrum.{Snowflake, Util}
  alias Nostrum.Struct.Guild.Member

  defstruct [
    :guild_id,
    :channel_id,
    :user_id,
    :member,
    :session_id,
    :deaf,
    :mute,
    :self_deaf,
    :self_mute,
    :self_stream,
    :suppress
  ]

  @typedoc "The guild id this voice state is for"
  @type guild_id :: Snowflake.t() | nil

  @typedoc "The channel id this user is connected to"
  @type channel_id :: Snowflake.t()

  @typedoc "The user id this voice state is for"
  @type user_id :: Snowflake.t()

  @typedoc "The guild member this voice state is for"
  @type member :: Member.t() | nil

  @typedoc "The session id for this voice state"
  @type session_id :: String.t()

  @typedoc "Whether this user is deafened by the server"
  @type deaf :: boolean

  @typedoc "Whether this user is muted by the server"
  @type mute :: boolean

  @typedoc "Whether this user is locally deafened"
  @type self_deaf :: boolean

  @typedoc "Whether this user is locally muted"
  @type self_mute :: boolean

  @typedoc "Whether this user is streaming using 'Go Live'"
  @type self_stream :: boolean | nil

  @typedoc "Whether this user is muted by the current user"
  @type suppress :: boolean

  @type t :: %__MODULE__{
          guild_id: guild_id,
          channel_id: channel_id,
          user_id: user_id,
          member: member,
          session_id: session_id,
          deaf: deaf,
          mute: mute,
          self_deaf: self_deaf,
          self_mute: self_mute,
          self_stream: self_stream,
          suppress: suppress
        }

  @doc false
  def p_encode do
    %__MODULE__{}
  end

  @doc false
  def to_struct(map) do
    new =
      map
      |> Map.new(fn {k, v} -> {Util.maybe_to_atom(k), v} end)
      |> Map.update(:guild_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:channel_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:session_id, nil, &Util.cast(&1, Snowflake))
      |> Map.update(:member, nil, &Util.cast(&1, {:struct, Member}))

    struct(__MODULE__, new)
  end
end
