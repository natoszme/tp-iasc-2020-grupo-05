defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  post "/" do
      buyerJson = conn.body_params
      id = BuyerHome.new(buyerJson)
      IO.inspect "new buyer id: #{id}"
      conn = Plug.Conn.put_resp_header(conn, "content-type", "application/json")
      send_resp(conn, 200, Poison.encode!(%{id: id}))
  end

  match _ do

   send_resp(conn, 404, "not found")

  end

end