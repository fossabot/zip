defmodule Zip.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Zip.Compiler.CodeServer
    ]

    children =
      if Application.get_env(:zip, :start_cli) do
        [%{id: Zip.Cli, start: {Zip.Cli, :start, [nil, nil]}} | children]
      else
        children
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zip.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
