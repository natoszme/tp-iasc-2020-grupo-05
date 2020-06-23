defmodule Buyers.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  post "/" do
      buyerJson = conn.body_params
      token = BuyerHome.new(buyerJson)
      IO.inspect "new buyer token: #{token}"
      conn = Plug.Conn.put_resp_header(conn, "content-type", "application/json")
      send_resp(conn, 200, Poison.encode!(%{token: token}))
  end

  match _ do

   send_resp(conn, 404, "not found")

  end

end