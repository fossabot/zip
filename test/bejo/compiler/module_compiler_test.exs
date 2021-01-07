defmodule Bejo.Compiler.ModuleCompilerTest do
  use ExUnit.Case, async: false

  alias Bejo.Compiler.{
    ModuleCompiler
  }

  test "given a file with bejo code, returns the compiled binary" do
    tmp_dir = System.tmp_dir!()
    temp_file = Path.join(tmp_dir, "foo.bejo")

    str = """
    fn foo : String do
      "Hello world"
    end
    """

    File.write!(temp_file, str)

    File.cd!(tmp_dir, fn ->
      assert {:ok, "foo", "foo.bejo", _binary} = ModuleCompiler.compile("foo")
    end)

    File.rm!(temp_file)
  end

  test "returns error when file doesn't exist" do
    module = Path.join(System.tmp_dir!(), "foo") |> String.to_atom()

    assert {:error, "Cannot read file #{module}.bejo: :enoent"} == ModuleCompiler.compile(module)
  end

  test "returns error when file cannot be parsed" do
    module = Path.join(System.tmp_dir!(), "foo") |> String.to_atom()

    temp_file = "#{module}.bejo"

    str = """
    function foo = "hello world"
    """

    File.write!(temp_file, str)

    assert {:error, "Parse error"} == ModuleCompiler.compile(module)

    File.rm!(temp_file)
  end

  test "returns error when type check fails" do
    module = Path.join(System.tmp_dir!(), "foo") |> String.to_atom()

    temp_file = "#{module}.bejo"

    str = """
    fn foo : Int do
      "Hello world"
    end
    """

    File.write!(temp_file, str)

    assert {:error, "Type check error"} == ModuleCompiler.compile(module)

    File.rm!(temp_file)
  end
end