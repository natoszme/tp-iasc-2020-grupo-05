defmodule Auction do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    IO.inspect state
    Registry.register(AuctionRegistry, state.id, {})
    Process.send_after(self(), :timeout, timeToTimeout(state))
    {:ok, state}
  end

  #TODO may be a cast
  def handle_call({:create_offer, offerJson}, _sender, state) do
    notifyOffer(state, offerJson)
    #TODO check if its better, otherwise same state
    #state = Map.put(state, :best_offer, {buyerIp, offerJson.price})
    {:reply, state, state}
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")

    #TODO find the winner and the other interested buyers (remove the winner from interested ones)
    #using the BuyerHome

    {:stop, :normal, state}
  end

  #just for testing
  def handle_info(:die, _state) do
    IO.puts("about to die")

    {:stop, :dead}
  end

  #TODO deconstruct map in param?
  def timeToTimeout(state) do
    Time.diff(state.endTime, Time.utc_now()) * 1000
  end

  def notifyOffer(state, offerJson) do
    Enum.each(interestedBuyers(state), &(notifyBuyerOffer(&1, state, offerJson)))
  end

  def interestedBuyers(state) do
    Buyer.Supervisor.interestedIn(state.tags)
  end

  def notifyBuyerOffer(buyer, state, offerJson) do
    id = state.id
    price = offerJson.price
    GenServer.cast(buyer, {:offer, {id, price}})
  end
end