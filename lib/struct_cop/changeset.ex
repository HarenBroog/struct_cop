defmodule StructCop.Changeset do
  @moduledoc false

  alias StructCop.Util
  import Ecto.Changeset

  def cast_all(%_{} = struct, attrs \\ %{}) do
    struct_mod =
      case struct do
        %Ecto.Changeset{data: %struct_mod{}} ->
          struct_mod

        %struct_mod{} ->
          struct_mod
      end

    changeset =
      struct
      |> cast(
        Util.destructurize(attrs),
        struct_mod.__schema__(:fields) -- struct_mod.__schema__(:embeds)
      )

    struct_mod.__schema__(:embeds)
    |> Enum.reduce(changeset, fn embed_name, changeset ->
      embed_module = struct_mod.__schema__(:embed, embed_name).related

      empty_value =
        case struct_mod.__schema__(:embed, embed_name).cardinality do
          :many -> []
          _ -> nil
        end

      destructrurize =
        if empty_value == [] do
          &Util.destructurize_many/1
        else
          &Util.destructurize/1
        end

      cast_function =
        if Util.struct_cop?(embed_module) do
          fn struct, attrs ->
            struct
            |> embed_module.changeset(attrs)
            |> embed_module.validate()
          end
        else
          &embed_module.changeset/2
        end

      changeset
      |> Map.update(:params, %{}, fn params ->
        params
        |> Map.update("#{embed_name}", empty_value, destructrurize)
      end)
      |> cast_embed(embed_name, with: cast_function)
    end)
  end
end
