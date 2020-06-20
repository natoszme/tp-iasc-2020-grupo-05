defmodule Bids.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  #TODO hacer todos los parseos en este controller
  post "/" do
    auctionJson = conn.body_params
    id = Auction.Supervisor.createAuction(auctionJson)

    send_resp(conn, 200, "created auction #{id}")
  end

  #TODO necesitamos un actor handler para este post porque no queremos tener toda la logica en el controller
  post "/:id/offer" do
      auction = GenServer.call(AuctionHome, {:auction_by_id, id})
      offerJson = conn.body_params
      #TODO esto se puede mejorar?
      case auction do
        :none -> send_resp(conn, 404, "inexisting auction #{id}")
        pid -> createOffer(conn, id, pid, offerJson)
      end
  end

  #TODO mejorar esto (parametros)
  def createOffer(conn, id, auction, offerJson) do
    senderIp = to_string(:inet_parse.ntoa(conn.remote_ip))
    buyer = GenServer.call(BuyerHome, {:buyer_by_ip, senderIp})
    GenServer.cast(auction, {:create_offer, buyer, offerJson})
    send_resp(conn, 200, "created offer for bid #{id}")
  end

  post "/:id/cancel" do
      send_resp(conn, 200, "cancelled auction #{id}")
  end

  match _ do
   send_resp(conn, 404, "not found")
  end

end