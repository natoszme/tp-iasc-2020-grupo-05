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

  #TODO necesitamos identificar el buyer a partir de la ip para notificar a todos menos ese!
  #necesitamos un actor handler para este post porque no queremos tener toda la logica en el controller
  post "/:id/offer" do
      auction = GenServer.call(AuctionHome, {:auction_by_id, id})
      offerJson = conn.body_params
      case auction do
        :none -> send_resp(conn, 404, "inexisting auction #{id}")
        pid -> createOffer(conn, id, pid, offerJson)
      end
  end

  #TODO mejorar esto
  def createOffer(conn, id, auction, offerJson) do
    GenServer.call(auction, {:create_offer, offerJson})
    send_resp(conn, 200, "created offer for bid #{id}")
  end

  post "/:id/cancel" do
      send_resp(conn, 200, "cancelled auction #{id}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do

   send_resp(conn, 404, "not found")

  end

end