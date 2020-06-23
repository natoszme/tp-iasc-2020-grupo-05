defmodule Auction.Agent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def saveOffer(auctionId, offer) do
    Agent.update(__MODULE__, &(_stateWithUpsertedAuction(&1, auctionId, offer)))
  end

  def bestOffer(auctionId) do
    case Agent.get(__MODULE__, &(Map.get(&1, auctionId))) do
      nil -> :none
      offer -> offer
    end
  end

  def removeAuction(auctionId) do
    Agent.update(__MODULE__, &(Map.delete(&1, auctionId)))
  end

  def _stateWithUpsertedAuction(state, auctionId, offer) do
    Map.put(state, auctionId, offer)
  end
end