defmodule Auction do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  #TODO needs an agent for keeping (id, best_offer)
  def init(state) do
    IO.inspect state
    Registry.register(AuctionRegistry, state.id, {})
    Process.send_after(self(), :timeout, timeToTimeout(state))
    {:ok, state}
  end

  def handle_cast({:create_offer, buyer, offerJson}, state) do
    newPrice = offerJson.price
    actualPrice = case actualPrice(state, newPrice) do
      {:better, betterPrice} ->
        notifyOffer(state, offerJson)
        betterPrice
      {_, actualPrice} ->
        actualPrice
    end
    
    buyerIp = GenServer.call(buyer, :ip)
    state = Map.put(state, :best_offer, %{ip: buyerIp, price: actualPrice})
    IO.inspect state
    {:noreply, state}
  end

  #TODO improve this crappy model
  def actualPrice(%{best_offer: %{price: bestPrice}}, newPrice) do
    _actualPrice(newPrice, bestPrice)
  end

  def actualPrice(%{basePrice: basePrice}, newPrice) do
    _actualPrice(newPrice, basePrice)
  end

  def _actualPrice(newPrice, actualPrice) do
    cond do
      newPrice > actualPrice ->
        {:better, newPrice}
      true ->
        {:worse, actualPrice}
    end
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")
    if state[:best_offer] do
      withoutPort = Enum.at(String.split(state.best_offer.ip, ":"), 0)
      winner = GenServer.call(BuyerHome, {:buyer_by_ip, withoutPort})
      IO.inspect winner

      bestPrice = state.best_offer.price
      GenServer.cast(winner, {:won, {state.id, bestPrice}})

      #TODO reuse between this and offer notification
      nonWinners = Buyer.Supervisor.interestedInBut(state.tags, winner)
      #TODO in order to test this properly, BuyerRegistry should distinguish ips by port!
      Enum.each(nonWinners, &(GenServer.cast(&1, {:lost, {state.id, bestPrice}})))
    end

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