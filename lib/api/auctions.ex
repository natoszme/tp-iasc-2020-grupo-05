defmodule Bids.Router do
  use Plug.Router
  use Plug.Debugger

  plug(:match)

  plug(:dispatch)

  #TODO hacer todos los parseos en este controller
  post "/" do
    auctionJson = conn.body_params
    {auction, id} = Auction.Supervisor.createAuction(auctionJson)

    GenServer.cast(auction, {:created})

    send_resp(conn, 200, "created auction #{id}")
  end

  post "/:id/offer" do
      offerAuctionHandler = RequestHandler.Supervisor.new(OfferAuctionHandler)
      case GenServer.call(offerAuctionHandler, {:create, conn, id}) do
        {:ok} -> send_resp(conn, 200, "created offer for auction ##{id}")
        {:error, message} -> send_resp(conn, 404, message)
      end
  end

  #TODO use CancelAuctionHandler
  #TODO reuse between /offer and /cancel
  post "/:id/cancel" do
      offerAuctionHandler = RequestHandler.Supervisor.new(OfferAuctionHandler)
      case GenServer.call(offerAuctionHandler, {:cancel, id}) do
        :ok -> send_resp(conn, 200, "cancelled auction #{id}")
        _ -> send_resp(conn, 404, "inexisting auction ##{id}")
      end
      send_resp(conn, 200, "cancelled auction #{id}")
  end

  match _ do
   send_resp(conn, 404, "not found")
  end

end