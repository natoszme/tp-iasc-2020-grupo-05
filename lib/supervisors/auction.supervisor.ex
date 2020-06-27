defmodule Auction.Supervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Auction.Supervisor ]
    DynamicSupervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  #TODO muy acopaldo a la auction? porque necesitamos calcular estos valores la sólo primera vez
  def createAuction(auctionJson) do
    endTime = DateTime.add(DateTime.utc_now(), String.to_integer(auctionJson.timeout), :second)
    auctionJson = Map.put(auctionJson, :endTime, endTime) |> Map.delete(:timeout)
    id = GenServer.call(IdGenerator, :next)
    auctionJson = Map.put(auctionJson, :id, id)
    auctionJson = %{auctionJson | basePrice: String.to_integer(auctionJson.basePrice)}
    {:ok, auction} = DynamicSupervisor.start_child(Auction.Supervisor, {Auction, auctionJson})
    Process.send_after(auction, :die, 2000)
    {auction, id}
  end
end