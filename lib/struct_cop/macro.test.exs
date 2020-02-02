defmodule StructCop.MacroTest do
  use ExUnit.Case, async: true

  describe "contract/1" do
    test "defines __schema__/1" do
      assert is_function(&TestStruct.__schema__/1)

      assert [
               :a,
               :b,
               :array,
               :map,
               :nesteds,
               :nested,
               :nested_ecto,
               :inline
             ] = TestStruct.__schema__(:fields)
    end
  end

  describe "new/1" do
    test "returns {:ok, struct}" do
      assert {:ok, %TestStruct{}} = TestStruct.new()
    end
  end

  describe "new!/1" do
    test "returns struct" do
      assert %TestStruct{} = TestStruct.new!()
    end

    test "raises ArgumentError when invalid" do
      assert_raise ArgumentError, fn ->
        TestStruct.new!(a: 5)
      end
    end
  end
end
