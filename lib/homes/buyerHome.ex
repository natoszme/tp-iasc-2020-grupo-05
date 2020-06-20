defmodule BuyerHome do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: BuyerHome)
  end

  def init(state) do
    Registry.start_link(keys: :unique, name: BuyerRegistry)
    {:ok, state}
  end

  def handle_call({:buyer_by_ip, ip}, _sender, state) do
    buyerRegister = Registry.lookup(BuyerRegistry, ip) |> List.first
    result = case buyerRegister do
      {buyer, _} -> buyer
      _ -> :none
    end

    {:reply, result, state}
  end
end