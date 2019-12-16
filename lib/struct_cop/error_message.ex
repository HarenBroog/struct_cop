defmodule StructCop.ErrorMessage do
  @moduledoc false

  def for(%Ecto.Changeset{} = changeset) do
    """
    cast failed for #{changeset.data |> inspect()}:

    params:
      #{changeset.params |> inspect()}
    errors:
      #{changeset.errors |> inspect()}
    """
  end

  def for(:invalid_struct, arg) do
    """
    Expected a struct which implements StructCop behaviour. Got: #{inspect(arg)}
    """
  end
end
