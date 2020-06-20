defmodule Bids.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  post "/" do
    auctionJson = conn.body_params
    id = Auction.Supervisor.createAuction(auctionJson)

    send_resp(conn, 200, "created auction #{id}")
  end

  post "/:id/offer" do
      auction = GenServer.call(AuctionHome, {:auction_by_id, id})
      case auction do
        :none -> send_resp(conn, 404, "inexisting auction #{id}")
        pid -> send_resp(conn, 200, "created offer for bid #{id}")
      end
  end

  post "/:id/cancel" do
      send_resp(conn, 200, "cancelled auction #{id}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end