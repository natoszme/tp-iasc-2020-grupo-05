defmodule AuctionHome do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: AuctionHome)
  end

  def init(state) do
    AuctionRegistry.start()
    {:ok, state}
  end

  def handle_call({:auction_by_id, id}, _sender, state) do
    auctionRegister = AuctionRegistry.auctionById(id)
    result = case auctionRegister do
      {auction, _} -> auction
      _ -> :none
    end

    {:reply, result, state}
  end
end