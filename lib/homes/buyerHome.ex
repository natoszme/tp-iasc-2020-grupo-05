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
    token = SecureRandom.urlsafe_base64
    buyerJson = Map.put(buyerJson, :token, token)
    Buyer.Supervisor.createBuyer(buyerJson)
    {:reply, token, state}
  end

  def handle_call({:by_token, token}, _sender, state) do
    buyerRegister = Registry.lookup(BuyerRegistry, token) |> List.first
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