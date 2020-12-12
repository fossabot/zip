defmodule Bejo.Parser do
  import NimbleParsec

  alias Bejo.ParserHelper, as: Helper

  horizontal_space =
    choice([
      string("\s"),
      string("\t")
    ])

  vertical_space =
    choice([
      string("\r"),
      string("\n")
    ])

  space =
    choice([vertical_space, horizontal_space])
    |> label("space or newline")

  require_space =
    space
    |> times(min: 1)
    |> ignore()

  allow_space =
    space
    |> repeat()
    |> ignore()

  keyword =
    choice([
      string("fn"),
      string("do"),
      string("end")
    ])

  identifier =
    lookahead_not(keyword)
    |> ascii_string([?a..?z], 1)
    |> ascii_string([?a..?z, ?_, ?0..?9], min: 0)
    |> reduce({Enum, :join, [""]})
    |> label("identifier")
    |> Helper.to_ast(:identifier)

  simple_type =
    ascii_string([?A..?Z], 1)
    |> ascii_string([?a..?z, ?A..?Z], min: 0)
    |> reduce({Enum, :join, [""]})
    |> Helper.to_ast(:simple_type)

  integer =
    integer(min: 1)
    |> label("integer")
    |> Helper.to_ast(:integer)

  string_exp =
    ignore(string("\""))
    |> repeat(choice([string("\\\""), utf8_char([not: ?"])]))
    |> ignore(string("\""))
    |> Helper.to_ast(:string)

  exp_paren =
    ignore(string("("))
    |> parsec(:exp)
    |> ignore(string(")"))
    |> label("expression in parentheses")

  call_args =
    optional(
      parsec(:exp)
      |> optional(
        allow_space
        |> ignore(string(","))
        |> concat(allow_space)
        |> parsec(:call_args)
      )
    )

  local_function_call =
    identifier
    |> ignore(string("("))
    |> wrap(call_args)
    |> ignore(string(")"))
    |> Helper.to_ast(:local_function_call)

  remote_function_call =
    identifier
    |> ignore(string("."))
    |> concat(identifier)
    |> ignore(string("("))
    |> wrap(call_args)
    |> ignore(string(")"))
    |> Helper.to_ast(:remote_function_call)

  function_call =
    choice([
      remote_function_call,
      local_function_call
    ])
    |> label("function call")

  exp_match =
    identifier
    |> concat(allow_space)
    |> ignore(string("="))
    |> concat(allow_space)
    |> parsec(:exp)
    |> label("match expression")
    |> Helper.to_ast(:exp_match)

  factor =
    choice([
      integer,
      string_exp,
      exp_paren,
      function_call,
      identifier
    ])

  term =
    factor
    |> optional(
      allow_space
      |> choice([string("*"), string("/")])
      |> concat(allow_space)
      |> parsec(:term)
    )

  exp_mult_op =
    Helper.to_ast(term, :exp_bin_op)

  exp_bin_op =
    exp_mult_op
    |> optional(
      allow_space
      |> choice([string("+"), string("-")])
      |> concat(allow_space)
      |> parsec(:exp_bin_op)
    )

  exp_add_op =
    Helper.to_ast(exp_bin_op, :exp_bin_op)

  exp =
    choice([
      exp_match,
      exp_add_op
    ])
    |> label("an expression")

  exps =
    parsec(:exp)
    |> optional(
      require_space
      |> parsec(:exps)
    )

  # Right now it's just simple one-worded types.
  # More complex types will come in here.
  type =
    simple_type

  arg =
    identifier
    |> concat(allow_space)
    |> ignore(string(":"))
    |> concat(allow_space)
    |> concat(type)
    |> Helper.to_ast(:arg)

  args =
    arg
    |> optional(
      allow_space
      |> ignore(string(","))
      |> concat(allow_space)
      |> parsec(:args)
    )

  arg_parens =
    choice([
      ignore(string("("))
      |> concat(allow_space)
      |> wrap(args)
      |> concat(allow_space)
      |> ignore(string(")")),

      empty() |> wrap()
    ])

  return_type =
    optional(
      allow_space
      |> ignore(string(":"))
      |> concat(allow_space)
      |> concat(type)
    )
    |> Helper.to_ast(:return_type)

  function_def =
    allow_space
    |> ignore(string("fn"))
    |> concat(require_space)
    |> concat(identifier)
    |> concat(arg_parens)
    |> concat(return_type)
    |> concat(require_space)
    |> ignore(string("do"))
    |> concat(require_space)
    |> wrap(exps)
    |> concat(require_space)
    |> ignore(string("end"))
    |> label("function definition")
    |> Helper.to_ast(:function_def)

  module =
    function_def
    |> times(min: 1)
    |> concat(allow_space)
    |> eos()

  def parse_module(str, module_name) do
    {:ok, ast, _, _, _, _} = parse(str)
    {:module, module_name, ast}
  end

  defcombinatorp :exp, exp
  defcombinatorp :exps, exps
  defcombinatorp :exp_bin_op, exp_bin_op
  defcombinatorp :term, term
  defcombinatorp :args, args
  defcombinatorp :call_args, call_args

  defparsec :parse, module

  # For testing
  defparsec :expression, exp |> concat(allow_space) |> eos()
  defparsec :function_def, function_def
end