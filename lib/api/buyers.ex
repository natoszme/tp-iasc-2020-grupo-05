defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)


  # Simple GET Request handler for path /hello
  get "/" do
      send_resp(conn, 200, "buyers")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end