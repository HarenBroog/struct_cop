defmodule StructCop.Config do
  @moduledoc false

  defstruct destructurize_keys: [:__struct__, :__schema__, :__meta__]
end
