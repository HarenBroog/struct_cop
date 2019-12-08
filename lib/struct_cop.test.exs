defmodule StructCopTest do
  use ExUnit.Case, async: true
  alias TestStruct, as: Subject

  describe "contract/1" do
    test "defines __schema__/1" do
      assert is_function(&Subject.__schema__/1)

      assert [
               :a,
               :b,
               :array,
               :map,
               :nesteds,
               :nested,
               :nested_ecto
             ] = Subject.__schema__(:fields)
    end
  end

  describe "new/1" do
    test "returns {:ok, struct}" do
      assert {:ok, %Subject{}} = Subject.new()
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

  describe "cast!/1" do
    test "returns {:ok, struct}" do
      assert %Subject{a: 4} = %Subject{a: 4} |> Subject.cast!()
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

  describe "cast/1" do
    test "returns {:ok, struct}" do
      assert {:ok, %Subject{a: 4}} = %Subject{a: 4} |> Subject.cast()
    end
  end

  describe "cast/2" do
    test "returns {:ok, struct}" do
      assert {:ok, %Subject{a: 4}} = %Subject{} |> Subject.cast(a: 4)
    end

    test "handles struct as attrs" do
      assert {:ok, %Subject{a: 4}} = %Subject{} |> Subject.cast(%Subject{a: 4})
    end

    test "returns {:error, %Ecto.Changeset{}}" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
               %Subject{} |> Subject.cast(a: 3)

      assert :a in Keyword.keys(errors)
    end
  end

  describe "cast/2 compound fileds" do
    test "casts array field" do
      assert {:ok, %Subject{array: [1, 2, 3]}} = %Subject{} |> Subject.cast(array: [1, 2, 3])
    end

    test "casts map field" do
      assert {:ok, %Subject{map: %{abc: 1, cde: 2}}} =
               %Subject{} |> Subject.cast(map: %{abc: 1, cde: 2})
    end
  end

  test "cast/2 for embeds_one with nested StructCop" do
    assert {:ok, %Subject{nested: %Subject.Nested{a: 1, b: 2}}} =
             %Subject{} |> Subject.cast(nested: %{a: 1, b: 2})

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nested: nested_changeset}}} =
             %Subject{} |> Subject.cast(nested: %{b: 2})

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end

  test "cast/2 for embeds_many with nested StructCop" do
    assert {:ok, %Subject{nesteds: [%Subject.Nested{a: 1, b: 2}]}} =
             %Subject{} |> Subject.cast(nesteds: [%{a: 1, b: 2}])

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nesteds: [nested_changeset]}}} =
             %Subject{} |> Subject.cast(nesteds: [%{b: 2}])

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end

  test "cast/2 for 2=level embeds_many with nested StructCop" do
    assert {:ok,
            %Subject{
              nesteds: [
                %Subject.Nested{a: 1, b: 2, deeply_nesteds: [%Subject.DeeplyNested{a: 1}]}
              ]
            }} = %Subject{} |> Subject.cast(nesteds: [%{a: 1, b: 2, deeply_nesteds: [%{a: 1}]}])
  end

  test "cast/2 for embeds_one with nested embedded_schema" do
    assert {:ok, %Subject{nested_ecto: %Subject.EctoSchema{a: 1}}} =
             %Subject{} |> Subject.cast(nested_ecto: %{a: 1})

    assert {:error, %Ecto.Changeset{valid?: false, changes: %{nested_ecto: nested_changeset}}} =
             %Subject{} |> Subject.cast(nested_ecto: %{b: 2})

    assert %Ecto.Changeset{valid?: false, errors: errors} = nested_changeset

    assert :a in Keyword.keys(errors)
  end
end
