defmodule StructCop do
  @type attrs() :: map() | keyword()

  @callback changeset(struct(), attrs()) :: %Ecto.Changeset{}
  @callback validate(%Ecto.Changeset{}) :: %Ecto.Changeset{}

  alias StructCop.Util

  defmacro __using__(args) do
    StructCop.Macro.use(args)
  end

  defmacro contract(args) do
    StructCop.Macro.contract(args)
  end

  def cast(%struct_mod{} = struct, attrs) do
    import Ecto.Changeset

    with {:ok, _} <- struct |> Util.ensure() do
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
  end

  def cast(_not_struct, _attrs) do
    {:error, :invalid_struct}
  end

  def cast!(struct, attrs) do
    struct
    |> Util.ensure!()
    |> cast(attrs)
    |> case do
      {:ok, result} ->
        result

      {:error, changeset} ->
        raise ArgumentError, StructCop.ErrorMessage.for(changeset)
    end
  end
end
