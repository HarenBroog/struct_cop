defmodule StructCop.TracerTest do
  use ExUnit.Case, async: true

  alias TestStruct.MyStruct
  alias TestStruct.Ordinary

  setup do
    Code.put_compiler_option(:tracers, [StructCop.Tracer])

    :ok
  end

  def compile(ast), do: Code.compile_quoted(ast)

  test "raises CompileError for %MyStruct{}" do
    assert_raise CompileError, fn ->
      quote do
        %MyStruct{}
      end
      |> compile()
    end

    assert_raise CompileError, fn ->
      quote do
        %MyStruct{} == %MyStruct{}
      end
      |> compile()
    end

    assert_raise CompileError, fn ->
      quote do
        struct = MyStruct.new!()
        %MyStruct{struct | a: 2}
      end
      |> compile()
    end

    assert_raise CompileError, fn ->
      quote do
        defmodule MyMacroMod do
          defmacro __using__(_) do
            quote do
              def call do
                %MyStruct{}
              end
            end
          end
        end

        defmodule MyClientMod do
          use MyMacroMod
        end
      end
      |> compile()
    end
  end

  test "raises CompileError for struct!(MyStruct, attrs)" do
    # TODO
  end

  test "doesn't raise CompileError for ordinary structs" do
    quote do
      %Ordinary{}
    end
    |> compile()

    assert true
  end

  test "doesn't raise for LEFT side of pattern match" do
    quote do
      defmodule MyMod do
        def call(%MyStruct{}) do
        end
      end
    end
    |> compile()

    quote do
      struct = MyStruct.new!(a: 2)

      %MyStruct{a: a} = struct
      %MyStruct{a: 2} = struct
    end
    |> compile()

    assert true
  end
end
