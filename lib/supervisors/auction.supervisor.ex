defmodule Auction.Supervisor do
  use Horde.DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Auction.Supervisor ]
    Horde.DynamicSupervisor.start_link(options)
  end

  def init(options) do
    {:ok, Keyword.put(options, :members, get_members())}
  end

  #TODO muy acopaldo a la auction? porque necesitamos calcular estos valores la sólo primera vez
  def createAuction(auctionJson) do
    endTime = DateTime.add(DateTime.utc_now(), String.to_integer(auctionJson.timeout), :second)
    auctionJson = Map.put(auctionJson, :endTime, endTime) |> Map.delete(:timeout)
    id = GenServer.call(IdGenerator, :next)
    auctionJson = Map.put(auctionJson, :id, id)
    auctionJson = %{auctionJson | basePrice: String.to_integer(auctionJson.basePrice)}
    auctionJson = Map.put(auctionJson, :originalNode, Node.self)
    {:ok, auction} = Horde.DynamicSupervisor.start_child(Auction.Supervisor, {Auction, auctionJson})
    #this won't work when distributed since its only for local pids
    #Process.send_after(auction, :die, 2000)
    IO.inspect "created auction on #{Node.self}"
    IO.inspect auction
    {auction, id}
  end

  defp get_members() do
    [Node.self() | Node.list()]
      |> Enum.map(fn node -> {MyHordeSupervisor, node} end)
  end
end