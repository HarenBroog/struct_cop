defmodule TestStruct.EctoSchema do
  use Ecto.Schema

  embedded_schema do
    field :a, :integer
  end

  def changeset(schema, attrs) do
    import Ecto.Changeset

    schema
    |> cast(attrs, [:a])
    |> validate_required([:a])
  end
end

defmodule TestStruct.DeeplyNested do
  use StructCop

  contract do
    field :a, :integer
  end

  def validate(changeset) do
    import Ecto.Changeset

    changeset
    |> validate_required([:a])
  end
end

defmodule TestStruct.Nested do
  use StructCop

  contract do
    field :a, :integer
    field :b, :integer
    embeds_many :deeply_nesteds, TestStruct.DeeplyNested
  end

  def validate(changeset) do
    import Ecto.Changeset

    changeset
    |> validate_required([:a])
  end
end

defmodule TestStruct do
  alias TestStruct.Nested
  alias TestStruct.EctoSchema
  use StructCop

  contract do
    field :a, :integer
    field :b, :integer
    field :array, {:array, :integer}
    field :map, :map
    embeds_many :nesteds, Nested
    embeds_one :nested, Nested
    embeds_one :nested_ecto, EctoSchema

    embeds_one :inline, InlineSchema do
      field :c, :integer
    end
  end

  def validate(changeset) do
    import Ecto.Changeset

    changeset
    |> validate_number(:a, less_than: 5)
    |> validate_number(:a, greater_than: 3)
  end
end
