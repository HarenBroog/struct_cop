defmodule StructCop.ChangesetTest do
  use ExUnit.Case, async: true
  alias StructCop.Changeset, as: Subject
  import Ecto.Changeset

  describe "cast_all/2" do
    test "works with %Ecto.Changeset{}" do
      assert %Ecto.Changeset{changes: %{b: 4, a: 4}} =
               %TestStruct{}
               |> cast(%{a: 4}, [:a])
               |> Subject.cast_all(b: 4)
    end

    test "fallbacks to &cast_all/2 for embeds without changeset" do
      assert %Ecto.Changeset{changes: %{inline: %Ecto.Changeset{changes: %{c: 10}}}} =
               %TestStruct{}
               |> Subject.cast_all(inline: %{c: 10})
    end
  end
end
