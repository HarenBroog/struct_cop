defmodule StructCop.ErrorMessage do
  def for(%Ecto.Changeset{} = changeset) do
    """
    cast failed for struct #{changeset.data |> inspect()}:

    changes:
      #{changeset.changes |> inspect()}
    errors:
      #{changeset.errors |> inspect()}
    """
  end
end
