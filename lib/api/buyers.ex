defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  plug(:dispatch)


  post "/" do
      GenServer.start_link(Buyer, conn.body_params)
      send_resp(conn, 200, "created buyer")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end