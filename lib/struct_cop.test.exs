defmodule StructCopTest do
  use ExUnit.Case, async: true

  describe "cast!/2" do
    test "returns struct" do
      assert %TestStruct{a: 4} = TestStruct.new!() |> StructCop.cast!(a: 4)
    end

    test "raises ArgumentError for invalid attrs" do
      assert_raise ArgumentError, fn ->
        TestStruct.new!()
        |> StructCop.cast!(a: 5)
      end
    end

    test "raises ArgumentError for invalid structs" do
      assert_raise ArgumentError, fn ->
        DateTime.utc_now()
        |> StructCop.cast!(a: 5)
      end

      assert_raise ArgumentError, fn ->
        nil
        |> StructCop.cast!(a: 5)
      end
    end
  end

  describe "cast/2" do
    test "returns {:ok, struct}" do
      assert {:ok, %TestStruct{a: 4}} = TestStruct.new!() |> StructCop.cast(a: 4)
    end

    test "handles struct as attrs" do
      assert {:ok, %TestStruct{a: 4}} = TestStruct.new!() |> StructCop.cast(TestStruct.new!(a: 4))
    end

    test "returns {:error, %Ecto.Changeset{}} for invalid attrs" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
               TestStruct.new!() |> StructCop.cast(a: 3)

      assert :a in Keyword.keys(errors)
    end

    test "returns {:error, :invalid_struct} for invalid structs" do
      assert {:error, :invalid_struct} =
               DateTime.utc_now()
               |> StructCop.cast(a: 5)

      assert {:error, :invalid_struct} =
               nil
               |> StructCop.cast(a: 5)
    end
  end

  describe "cast/2 for compound fileds" do
    test "casts array field" do
      assert {:ok, %TestStruct{array: [1, 2, 3]}} =
               TestStruct.new!() |> StructCop.cast(array: [1, 2, 3])
    end

    test "casts map field" do
      assert {:ok, %TestStruct{map: %{abc: 1, cde: 2}}} =
               TestStruct.new!() |> StructCop.cast(map: %{abc: 1, cde: 2})
    end
  end

  test "cast/2 for embeds_one with nested StructCop" do
    assert {:ok, %TestStruct{nested: %TestStruct.Nested{a: 1, b: 2}}} =
             TestStruct.new!() |> StructCop.cast(nested: %{a: 1, b: 2})

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nested: nested_changeset}}} =
             TestStruct.new!() |> StructCop.cast(nested: %{b: 2})

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end

  test "cast/2 for embeds_many with nested StructCop" do
    assert {:ok, %TestStruct{nesteds: [%TestStruct.Nested{a: 1, b: 2}]}} =
             TestStruct.new!() |> StructCop.cast(nesteds: [%{a: 1, b: 2}])

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nesteds: [nested_changeset]}}} =
             TestStruct.new!() |> StructCop.cast(nesteds: [%{b: 2}])

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end

  test "cast/2 for 2=level embeds_many with nested StructCop" do
    assert {:ok,
            %TestStruct{
              nesteds: [
                %TestStruct.Nested{a: 1, b: 2, deeply_nesteds: [%TestStruct.MyStruct{a: 1}]}
              ]
            }} =
             TestStruct.new!()
             |> StructCop.cast(nesteds: [%{a: 1, b: 2, deeply_nesteds: [%{a: 1}]}])
  end

  test "cast/2 for embeds_one with nested embedded_schema" do
    assert {:ok, %TestStruct{nested_ecto: %TestStruct.EctoSchema{a: 1}}} =
             TestStruct.new!() |> StructCop.cast(nested_ecto: %{a: 1})

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nested_ecto: nested_changeset}}} =
             TestStruct.new!() |> StructCop.cast(nested_ecto: %{b: 2})

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end
end
