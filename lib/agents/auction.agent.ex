defmodule Auction.Agent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def saveOffer(auctionId, offer) do
    Agent.update(__MODULE__, &(_stateWithUpsertedAuction(&1, auctionId, offer)))
  end

  def _stateWithUpsertedAuction(state, auctionId, offer) do
    Map.put(state, auctionId, offer)
  end

  def _auctionExists(state, auctionId) do
    Map.has_key?(state, auctionId)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end