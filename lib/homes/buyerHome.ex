defmodule BuyerHome do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: BuyerHome)
  end

  def init(state) do
    Registry.start_link(keys: :unique, name: BuyerRegistry)
    {:ok, state}
  end

  def handle_call({:create, buyerJson}, _sender, state) do
    id = SecureRandom.base64
    buyerJson = Map.put(buyerJson, :id, id)
    Buyer.Supervisor.createBuyer(buyerJson)
    {:reply, id, state}
  end

  def handle_call({:buyer_by_ip, ip}, _sender, state) do
    buyerRegister = Registry.lookup(BuyerRegistry, ip) |> List.first
    result = case buyerRegister do
      {buyer, _} -> buyer
      _ -> :none
    end

    {:reply, result, state}
  end

  def new(buyerJson) do
    GenServer.call(__MODULE__, {:create, buyerJson})
  end
end