defmodule Bejo.ParserHelper do
  import NimbleParsec

  def to_ast(c, kind) do
    c
    |> line()
    |> byte_offset()
    |> map({Bejo.ParserHelper, :put_line_offset, []})
    |> map({Bejo.ParserHelper, :do_to_ast, [kind]})
  end


  def put_line_offset({[{result, {line, line_start_offset}}], string_offset}) do
    {result, {line, line_start_offset, string_offset}}
  end

  def do_to_ast({[value], line}, :integer) do
    {:integer, line, value}
  end

  def do_to_ast({[left, bin_op, right | rest], line}, :exp_bin_op) when bin_op in ["+", "-", "*", "/"] do
    new_left = {:call, {String.to_atom(bin_op), line}, [left, right], :kernel}
    do_to_ast({[new_left | rest], line}, :exp_bin_op)
  end

  def do_to_ast({[result], _line}, :exp_bin_op) do
    result
  end

  def do_to_ast({[name], line}, :identifier) do
    {:identifier, line, String.to_atom(name)}
  end

  def do_to_ast({[name, type, exps], line}, :function_def) do
    {:identifier, _, name} = name
    args = []
    {:function, [position: line], {name, args, type, exps}}
  end

  def do_to_ast({[], line}, :return_type) do
    {:type, line, "Nothing"}
  end

  def do_to_ast({[type], _line}, :return_type) do
    type
  end

  def do_to_ast({[name], line}, :simple_type) do
    {:type, line, name}
  end
end