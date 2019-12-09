defmodule StructCop.ErrorMessage do
  @moduledoc false

  def for(%Ecto.Changeset{} = changeset) do
    """
    cast failed for struct #{changeset.data |> inspect()}:

    params:
      #{changeset.params |> inspect()}
    errors:
      #{changeset.errors |> inspect()}
    """
  end
end
