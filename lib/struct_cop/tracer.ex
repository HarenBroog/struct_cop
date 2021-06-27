defmodule StructCop.Tracer do
  def trace({:struct_expansion, _meta, _module, _keys}, %Macro.Env{context: :match}), do: :ok

  def trace({:struct_expansion, _meta, module, _keys}, env) do
    if function_exported?(module, :__struct_cop__, 0) &&
         module.__struct_cop_enforce_constructor__() do
      raise CompileError,
        file: env.file,
        line: env.line,
        description: """

          #{struct_label(module)} enforces constructors usage (new/1 & new!/1),
          ordinary struct creation is not allowed:

          * #{struct_label(module)}
          * #{struct_label(module, "struct | arg: 123")}
        """
    else
      :ok
    end
  end

  def trace(_, _), do: :ok

  defp struct_label(module, content \\ nil) do
    "%#{inspect(module)}{#{content}}"
  end
end
