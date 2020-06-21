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

  def handle_cast({:create_offer, buyer, %{price: newPrice}}, state) do
    actualPrice = case actualPrice(state, newPrice) do
      {:better, betterPrice} ->
        notifyOffer(state, newPrice)
        betterPrice
      {_, actualPrice} ->
        actualPrice
    end
    
    buyerIp = GenServer.call(buyer, :ip)
    state = Map.put(state, :best_offer, %{ip: buyerIp, price: actualPrice})
    IO.inspect state
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")

    case state do
      %{best_offer: _} -> notifyWinner(state)
      _ -> nil
    end

    {:stop, :normal, state}
  end

  #just for testing
  def handle_info(:die, _state) do
    IO.puts("about to die")

    {:stop, :dead}
  end

  def actualPrice(state, newPrice) do
    case state do
      %{best_offer: %{price: bestPrice}} -> _actualPrice(newPrice, bestPrice)
      %{basePrice: basePrice} -> _actualPrice(newPrice, basePrice)
    end    
  end

  def _actualPrice(newPrice, actualPrice) do
    cond do
      newPrice > actualPrice ->
        {:better, newPrice}
      true ->
        {:worse, actualPrice}
    end
  end

  def notifyWinner(%{id: id, tags: tags, best_offer: %{price: bestPrice, ip: ip}}) do
    withoutPort = Enum.at(String.split(ip, ":"), 0)
    winner = GenServer.call(BuyerHome, {:buyer_by_ip, withoutPort})
    IO.inspect winner

    GenServer.cast(winner, {:won, {id, bestPrice}})

    #TODO reuse between this and offer notification
    nonWinners = Buyer.Supervisor.interestedInBut(tags, winner)
    #TODO in order to test this properly, BuyerRegistry should distinguish ips by port!
    Enum.each(nonWinners, &(GenServer.cast(&1, {:lost, {id, bestPrice}})))
  end

  #TODO deconstruct map in param?
  def timeToTimeout(state) do
    Time.diff(state.endTime, Time.utc_now()) * 1000
  end

  def notifyOffer(state, newPrice) do
    Enum.each(interestedBuyers(state), &(notifyBuyerOffer(&1, state, newPrice)))
  end

  #TODO should get them from BuyerHome!
  def interestedBuyers(state) do
    Buyer.Supervisor.interestedIn(state.tags)
  end

  def notifyBuyerOffer(buyer, %{id: id}, newPrice) do
    GenServer.cast(buyer, {:offer, {id, newPrice}})
  end
end