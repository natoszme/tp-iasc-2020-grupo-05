defmodule BuyerHome do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: BuyerHome)
  end

  def init(state) do
    BuyerRegistry.start()
    {:ok, state}
  end

  def handle_call({:create, buyerJson}, _sender, state) do
    token = SecureRandom.urlsafe_base64
    buyerJson = Map.put(buyerJson, :token, token)
    Buyer.Supervisor.createBuyer(buyerJson)
    {:reply, token, state}
  end

  def handle_call({:by_token, token}, _sender, state) do
    buyerRegister = BuyerRegistry.buyerByToken(token)
    result = case buyerRegister do
      {buyer, _} -> buyer
      _ -> :none
    end

    {:reply, result, state}
  end

  def new(buyerJson) do
    GenServer.call(__MODULE__, {:create, buyerJson})
  end

  #TODO use BuyerRegistry
  #TODO may look for interested saving the interested tags in the value and the Registry.match/4
  def interestedIn(tags) do
    childs = Horde.DynamicSupervisor.which_children(Buyer.Supervisor)
    Enum.filter(childs, &(_childInterestedIn?(&1, tags)))
      |> Enum.map(&(elem(&1, 1)))
  end

  def interestedInBut(tags, buyer) do
    interestedBuyers = interestedIn(tags)
    Enum.filter(interestedBuyers, &(&1 != buyer))
  end

  def _childInterestedIn?(fullChild, tags) do
    child = elem(fullChild, 1)
    GenServer.call(child, {:interested?, tags})
  end
end