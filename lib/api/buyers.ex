defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(:dispatch)


  # Simple GET Request handler for path /hello
  get "/" do
      send_resp(conn, 200, "buyers")
  end

end