defmodule StructCop.Macro do
  @moduledoc false

  defmacro __using__(_args) do
    quote do
      @behaviour StructCop
      require StructCop.Macro
      import StructCop.Macro, only: [contract: 1]

      def changeset(%_{} = struct, attrs) do
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
      def __struct_cop_enforce_constructor__, do: true

      defoverridable changeset: 2
      defoverridable validate: 1
    end
  end

  defmacro contract(do: block) do
    quote do
      use Ecto.Schema

      @primary_key false
      embedded_schema do
        unquote(block)
      end
    end
  end
end
