defmodule TestStruct do
  use StructCop

  contract do
    field :a, :integer
  end

  def changeset(changeset, attrs) do
    import Ecto.Changeset

    changeset
    |> super(attrs)
    |> validate_number(:a, less_than: 5)
    |> validate_number(:a, greater_than: 3)
  end
end
