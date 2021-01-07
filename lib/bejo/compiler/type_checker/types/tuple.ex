defmodule Bejo.Compiler.TypeChecker.Types.Tuple do
  defstruct elements: []

  alias Bejo.Compiler.TypeChecker.Types, as: T

  defimpl String.Chars, for: T.Tuple do
    def to_string(%{elements: elements}) do
      elements_str = T.Helper.join_list(elements)
      "{#{elements_str}}"
    end
  end
end
