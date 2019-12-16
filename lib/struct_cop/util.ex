defmodule StructCop.Util do
  @moduledoc false

  @config %StructCop.Config{}

  def ensure(%struct_mod{} = struct) do
    if struct_cop?(struct_mod) do
      {:ok, struct}
    else
      {:error, :invalid_struct}
    end
  end

  def ensure(_), do: {:error, :invalid_struct}

  def ensure!(struct) do
    with {:ok, _} <- ensure(struct) do
      struct
    else
      _ ->
        raise ArgumentError, StructCop.ErrorMessage.for(:invalid_struct, struct)
    end
  end

  def struct_cop?(module), do: function_exported?(module, :__struct_cop__, 0)

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
