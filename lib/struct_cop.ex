defmodule StructCop do
  @type attrs() :: map() | keyword()

  @callback changeset(struct(), attrs()) :: %Ecto.Changeset{}
  @callback validate(%Ecto.Changeset{}) :: %Ecto.Changeset{}

  alias StructCop.Util

  defmacro __using__(_) do
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

      defdelegate cast(struct), to: StructCop
      defdelegate cast!(struct), to: StructCop
      defdelegate cast(struct, attrs), to: StructCop
      defdelegate cast!(struct, attrs), to: StructCop

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

  def cast(%struct_mod{} = struct) do
    struct_mod
    |> struct()
    |> cast(struct)
  end

  def cast(%struct_mod{} = struct, attrs) do
    import Ecto.Changeset

    struct
    |> struct_mod.changeset(attrs |> Util.destructurize())
    |> struct_mod.validate()
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes()}

      changeset ->
        {:error, changeset}
    end
  end

  def cast!(%struct_mod{} = struct) do
    struct_mod
    |> struct()
    |> cast!(struct)
  end

  def cast!(struct, attrs) do
    struct
    |> cast(attrs)
    |> case do
      {:ok, result} ->
        result

      {:error, changeset} ->
        raise ArgumentError, StructCop.ErrorMessage.for(changeset)
    end
  end
end
