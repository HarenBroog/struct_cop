defmodule StructCop do
  @type attrs() :: map() | keyword()

  @callback changeset(struct(), attrs()) :: %Ecto.Changeset{}

  defmacro __using__(_) do
    quote do
      @behaviour StructCop
      import StructCop, only: [contract: 1]

      def changeset(struct, attrs \\ %{}) do
        import Ecto.Changeset

        struct
        |> StructCop.cast_all(attrs)
      end

      defdelegate cast(struct, attrs), to: StructCop
      defdelegate cast!(struct, attrs), to: StructCop

      defoverridable changeset: 2

      @before_compile StructCop
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def new(attrs \\ %{}) do
        import StructCop
        import Ecto.Changeset

        %__MODULE__{}
        |> StructCop.changeset(attrs |> sanitize_attrs())
        |> apply_changes()
      end

      def new!(attrs \\ %{}) do
        %__MODULE__{}
        |> StructCop.cast!(attrs)
      end
    end
  end

  defmacro contract(do: block) do
    quote do
      use Ecto.Schema

      @derive Jason.Encoder
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
    |> struct_mod.changeset(attrs |> sanitize_attrs())
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes()}

      changeset ->
        {:error, changeset}
    end
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

  def cast_all(%struct_mod{} = struct, attrs \\ %{}) do
    import Ecto.Changeset

    changeset =
      struct
      |> cast(
        attrs,
        struct_mod.__schema__(:fields) -- struct_mod.__schema__(:embeds)
      )

    struct_mod.__schema__(:embeds)
    |> Enum.reduce(changeset, fn embed_name, changeset ->
      changeset
      |> Map.update(:params, %{}, fn params ->
        params
        |> Map.update("#{embed_name}", nil, &destructurize/1)
      end)
      |> cast_embed(embed_name)
    end)
  end

  def sanitize_attrs(attrs) do
    attrs
    |> Enum.into(%{})
    |> Map.drop([:__struct__, :__schema__, :__meta__])
  end

  defp destructurize(maybe_structs) when is_list(maybe_structs) do
    maybe_structs
    |> Enum.map(&destructurize/1)
  end

  defp destructurize(%_{} = struct) do
    struct
    |> Map.drop([:__struct__, :__schema__, :__meta__])
  end

  defp destructurize(any), do: any
end
