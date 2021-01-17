defmodule Zip.Deploy do
  def copy_files(args) do
    path = "_build/#{Mix.env()}/rel/bakeware/zip"

    File.cp!(path, "./zip")
    IO.puts("Zip executable available at #{File.cwd!()}/zip")
    args
  end

  def set_env(args) do
    System.put_env("ZIP_RUN_CLI", "true")
    args
  end
end
