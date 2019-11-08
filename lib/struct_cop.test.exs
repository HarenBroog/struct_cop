defmodule StructCopTest do
  use ExUnit.Case
  alias TestStruct, as: Subject

  describe "contract/1" do
    test "defines __schema__/1" do
      assert is_function(&Subject.__schema__/1)

      assert [
               :a
             ] = Subject.__schema__(:fields)
    end
  end

  describe "new!/1" do
    test "returns struct" do
      assert %Subject{} = Subject.new!()
    end

    test "raises ArgumentError when invalid" do
      assert_raise ArgumentError, fn ->
        Subject.new!(a: 5)
      end
    end
  end

  describe "cast!/2" do
    test "returns struct" do
      assert %Subject{a: 4} = %Subject{} |> Subject.cast!(a: 4)
    end

    test "raises ArgumentError when invalid" do
      assert_raise ArgumentError, fn ->
        %Subject{}
        |> Subject.cast!(a: 5)
      end
    end
  end
end
