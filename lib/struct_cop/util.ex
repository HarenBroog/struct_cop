defmodule StructCop.Util do
  @config %StructCop.Config{}

  def destructurize_many(maybe_structs) when is_list(maybe_structs) do
    maybe_structs
    |> Enum.map(&destructurize/1)
  end

  def destructurize(%_{} = struct) do
    struct
    |> Map.drop(@config.destructurize_keys)
  end

  def destructurize(list) when is_list(list), do: list |> Enum.into(%{})
  def destructurize(any), do: any
end
