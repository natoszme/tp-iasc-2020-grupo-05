defmodule Bids.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  post "/" do
    body = conn.body_params
    GenServer.start_link(Auction, body)

    send_resp(conn, 201, "created bid with tags #{body.tags}")
  end

  post "/:id/offer" do
      send_resp(conn, 200, "created offer for bid #{id}")
  end

  post "/:id/cancel" do
      send_resp(conn, 200, "cancelled bid #{id}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end