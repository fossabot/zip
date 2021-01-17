defmodule Zip.Router do
  use Application

  import Plug.Conn

  def start(_, _) do
    children = [
      {Zip.RouteStore, []},
      {Plug.Cowboy, scheme: :http, plug: Zip.Router, options: [port: 6060, ip: {127, 0, 0, 1}]}
    ]

    opts = [strategy: :one_for_one, name: Zip.Cli.Router.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    {status, resp} = get_resp(conn.method, conn.request_path)
    send_resp(conn, status, resp)
  end

  def home do
    "It's zip time!"
  end

  defp get_resp(method, path) do
    case Zip.RouteStore.get_route(method, path) do
      nil ->
        {404, "Not found"}

      function ->
        body = function.()
        {200, body}
    end
  end
end
