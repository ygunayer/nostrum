defmodule Nostrum.Struct.Guild.Voice.Region do
  @moduledoc ~S"""
  Struct representing a Discord voice region.
  """

  alias Nostrum.{Snowflake, Util}

  defstruct [
    :id,
    :name,
    :vip,
    :optimal,
    :deprecated,
    :custom
  ]

  @typedoc "Unique ID for the region"
  @type id :: Snowflake.t()

  @typedoc "Unique ID for the region"
  @type name :: String.t()

  @typedoc "True if this is a vip-only server"
  @type vip :: boolean

  @typedoc "True for a single server that is closest to the current user's client"
  @type optimal :: boolean

  @typedoc "Whether this is a deprecated voice region (avoid switching to these)"
  @type deprecated :: boolean

  @typedoc "Whether this is a custom voice region (used for events/etc)"
  @type custom :: boolean

  @type t :: %__MODULE__{
          id: id,
          name: name,
          vip: vip,
          optimal: optimal,
          deprecated: deprecated,
          custom: custom
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
      |> Map.update(:id, nil, &Util.cast(&1, Snowflake))

    struct(__MODULE__, new)
  end
end
