defmodule Nostrum.Struct.Guild.Voice.Server do
  @moduledoc ~S"""
  Struct representing a Discord voice server.
  """

  alias Nostrum.{Snowflake, Util}

  defstruct [
    :token,
    :guild_id,
    :endpoint
  ]

  @typedoc "Unique ID for the region"
  @type token :: String.t() | nil

  @typedoc "The guild this voice server update is for"
  @type guild_id :: Snowflake.t()

  @typedoc "Unique ID for the region"
  @type endpoint :: String.t() | nil

  @type t :: %__MODULE__{
          token: token,
          guild_id: guild_id,
          endpoint: endpoint
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

    struct(__MODULE__, new)
  end
end
