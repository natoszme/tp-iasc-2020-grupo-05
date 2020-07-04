defmodule Auction.Agent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def saveOffer(auctionId, offer) do
    Agent.update(__MODULE__, &(_stateWithUpsertedAuction(&1, auctionId, offer)))
  end

  def saveAndSyncOffer(auctionId, offer) do
    saveOffer(auctionId, offer)
    NodeListener.syncOffer(auctionId, offer)
  end

  def bestOffer(auctionId) do
    case Agent.get(__MODULE__, &(Map.get(&1, auctionId))) do
      nil -> :none
      offer -> offer
    end
  end

  def allState() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def syncState(stateToSync) do
    IO.inspect stateToSync
    Map.to_list(stateToSync)
      |> Enum.each(&(syncOffer(&1)))
  end

  def syncOffer({id, offer}) do
    IO.inspect "about to update best offer for auction #{id}"
    saveOffer(id, offer)
  end

  def _stateWithUpsertedAuction(state, auctionId, offer) do
    Map.put(state, auctionId, offer)
  end
end