defmodule OfferAuctionHandler do
  use Task, restart: :transient

  def start_link(_args) do
    Task.start_link(__MODULE__)
  end

  #TODO retry on failing, doing the call on init?
  def init(state) do
    {:ok, state}
  end

  def create({conn, id}) do
    auction = GenServer.call(AuctionHome, {:auction_by_id, id})
    offerJson = conn.body_params

    #TODO esto se puede mejorar?
    case auction do
      :none ->
        {:error, "inexisting auction ##{id}"}
      pid ->
        createOffer(conn, pid, offerJson)
    end
  end

  #TODO avoid logic repeating
  def cancel(id) do
    auction = GenServer.call(AuctionHome, {:auction_by_id, id})

    #TODO esto se puede mejorar?
    case auction do
      :none ->
        :error
      pid ->
        cancelAuction(pid)
        :ok
    end
  end

  #TODO mejorar esto (parametros)
  def createOffer(conn, auction, offerJson) do
    token = conn.query_params["token"]
    case GenServer.call(BuyerHome, {:by_token, token}) do
      :none -> {:error, "inexisting buyer with token #{token}"}
      buyer ->
        GenServer.cast(auction, {:create_offer, {buyer, token}, offerJson})
        {:ok}
    end
  end

  #TODO mejorar esto (parametros)
  def cancelAuction(auction) do
    GenServer.cast(auction, {:cancel})
  end
end