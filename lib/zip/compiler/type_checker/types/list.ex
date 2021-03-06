defmodule Zip.Compiler.TypeChecker.Types.List do
  defstruct type: :Nothing

  defimpl String.Chars, for: Zip.Compiler.TypeChecker.Types.List do
    def to_string(%{type: type}) do
      "List(#{type})"
    end
  end
end
