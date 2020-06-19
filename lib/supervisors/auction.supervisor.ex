defmodule Auction.Supervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Auction.Supervisor ]
    DynamicSupervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  def createAuction(auctionJson) do
    DynamicSupervisor.start_child(Auction.Supervisor, {Auction, auctionJson})
  end
end