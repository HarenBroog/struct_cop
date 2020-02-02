defmodule StructCop.ErrorMessageTest do
  use ExUnit.Case, async: true

  alias StructCop.ErrorMessage, as: Subject

  def changeset do
    import Ecto.Changeset

    %TestStruct{}
    |> cast(%{a: 4}, [:a])
    |> validate_number(:a, greater_than: 5)
    |> validate_number(:a, less_than: 3)
  end

  describe "for/1" do
    setup do
      [subject: fn -> changeset() |> Subject.for() end]
    end

    test "contains struct name", %{subject: subject} do
      assert subject.() =~ "TestStruct"
    end
  end
end
