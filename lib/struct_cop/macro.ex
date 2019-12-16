defmodule StructCop.Macro do
  def use(_args) do
    quote do
      @behaviour StructCop
      import StructCop, only: [contract: 1]

      def changeset(%_{} = struct, attrs \\ %{}) do
        struct
        |> StructCop.Changeset.cast_all(attrs)
      end

      def validate(changeset), do: changeset

      def new(attrs \\ %{}) do
        __MODULE__.__struct__()
        |> StructCop.cast(attrs)
      end

      def new!(attrs \\ %{}) do
        __MODULE__.__struct__()
        |> StructCop.cast!(attrs)
      end

      def __struct_cop__, do: true

      defoverridable changeset: 2
      defoverridable validate: 1
    end
  end

  def contract(do: block) do
    quote do
      use Ecto.Schema

      @primary_key false
      embedded_schema do
        unquote(block)
      end
    end
  end
end
