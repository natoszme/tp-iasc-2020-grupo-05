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
    endTime = Time.add(Time.utc_now(), String.to_integer(auctionJson.timeout), :second)
    auctionJson = Map.put(auctionJson, :endTime, endTime)
    {:ok, auction} = DynamicSupervisor.start_child(Auction.Supervisor, {Auction, auctionJson})
    Process.send_after(auction, :die, 2000)
  end
end