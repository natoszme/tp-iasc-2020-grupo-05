defmodule Auction do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  #TODO needs an agent for keeping (id, offers)
  def init(state) do
    IO.inspect state
    Registry.register(AuctionRegistry, state.id, {})
    Process.send_after(self(), :timeout, timeToTimeout(state))
    {:ok, state}
  end

  def handle_cast({:create_offer, buyer, offerJson}, state) do
    #TODO notify only if its better
    notifyOffer(state, offerJson)

    price = offerJson.price
    betterPrice = betterOrSamePrice(state, price)    
    
    buyerIp = GenServer.call(buyer, :ip)
    state = Map.put(state, :best_offer, %{ip: buyerIp, price: betterPrice})
    IO.inspect state
    {:noreply, state}
  end

  #TODO improve this crappy model
  def betterOrSamePrice(state, price) do
    cond do
      !state[:best_offer] ->
        IO.inspect "no best_offer"
        cond do
          price > state.basePrice ->
            IO.inspect "first price is better than basePrice"
            price
          true -> state.basePrice
        end
      true ->
        IO.inspect price
        IO.inspect state.best_offer.price
        cond do
          price > state.best_offer.price ->
            IO.inspect "new best offer"
            price
          true -> state.best_offer.price
      end
    end
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")

    #TODO handle that may not be best_offer
    withoutPort = Enum.at(String.split(state.best_offer.ip, ":"), 0)
    winner = GenServer.call(BuyerHome, {:buyer_by_ip, withoutPort})
    IO.inspect winner

    bestPrice = state.best_offer.price
    GenServer.cast(winner, {:won, {state.id, bestPrice}})

    #TODO reuse between this and offer notification
    nonWinners = Buyer.Supervisor.interestedInBut(state.tags, winner)
    #TODO in order to test this properly, BuyerRegistry should distinguish ips by port!
    Enum.each(nonWinners, &(GenServer.cast(&1, {:lost, {state.id, bestPrice}})))

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

  #TODO should get them from BuyerHome!
  def interestedBuyers(state) do
    Buyer.Supervisor.interestedIn(state.tags)
  end

  def notifyBuyerOffer(buyer, state, offerJson) do
    id = state.id
    price = offerJson.price
    GenServer.cast(buyer, {:offer, {id, price}})
  end
end