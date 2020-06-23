defmodule OfferAuctionHandler do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  #TODO retry on failing, doing the call on init?
  def init(state) do
    {:ok, state}
  end

  #TODO should die after this call!
  def handle_call({:create, conn, id}, _sender, state) do
    auction = GenServer.call(AuctionHome, {:auction_by_id, id})
    offerJson = conn.body_params

    #TODO esto se puede mejorar?
    reply = case auction do
      :none ->
        :error
      pid ->
        createOffer(conn, pid, offerJson)
        :ok
    end

    {:reply, reply, state}
  end

  #TODO mejorar esto (parametros)
  def createOffer(conn, auction, offerJson) do
    token = conn.query_params["token"]
    #TODO validate that buyer exists
    buyer = GenServer.call(BuyerHome, {:by_token, token})
    GenServer.cast(auction, {:create_offer, {buyer, token}, offerJson})
  end
end