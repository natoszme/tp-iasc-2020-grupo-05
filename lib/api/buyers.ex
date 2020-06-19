defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  post "/" do
      buyerJson = conn.body_params
      Buyer.Supervisor.createBuyer(buyerJson)
      send_resp(conn, 200, "created buyer #{buyerJson.name}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end