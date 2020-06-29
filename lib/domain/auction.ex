defmodule Auction do
  use GenServer, restart: :transient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Horde.Registry.register(Auction.Registry, state.id, {})
    state = addTimeIfNeeded(state)
    Process.send_after(self(), :timeout, timeToTimeout(state))

    state = case Auction.Agent.bestOffer(state.id) do
      :none -> state
      %{price: actualPrice, buyer: token} -> stateWithUpdatedPrice(state, actualPrice, token)
    end

    IO.inspect state

    {:ok, state}
  end

  def terminate(:normal, %{id: id}) do
    Auction.Agent.removeAuction(id)
  end

  def terminate({:bad_return_value, {:stop, :dead}}, _state) do
    "i died :("
  end

  def handle_cast({:created}, state) do
    IO.inspect "notifying creation of auction #{state.id}"
    notifyAll(state, :new_auction)
    {:noreply, state}
  end

  def handle_cast({:create_offer, {buyer, token}, %{price: newPrice}}, state) do
    IO.inspect "received offer with price #{newPrice}"


    actualPrice = case actualPrice(state, newPrice) do
      {:better, betterPrice} ->
        notifyOffer(state, buyer, newPrice)
        updateOffer(state, newPrice, token)
        betterPrice
      {_, actualPrice} ->
        actualPrice
    end

    updatedState = stateWithUpdatedPrice(state, actualPrice, token)

    {:noreply, updatedState}
  end

  def handle_cast({:cancel}, state) do
    IO.inspect "about to cancel #{state.id}"

    notifyAll(state, :cancelled)

    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")

    case state do
      %{best_offer: _} -> notifyEnd(state)
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

  def updateOffer(%{id: id}, actualPrice, token) do
    Auction.Agent.saveAndSyncOffer(id, _offer(token, actualPrice))
  end

  def stateWithUpdatedPrice(state, actualPrice, token) do
    Map.put(state, :best_offer, _offer(token, actualPrice))
  end

  def _offer(buyerToken, price) do
    %{price: price, buyer: buyerToken}
  end

  def notifyEnd(state) do
    winner = notifyWinner(state)
    notifyLosers(state, winner)
  end

  def timeToTimeout(%{endTime: endTime}) do
    DateTime.diff(endTime, DateTime.utc_now()) * 1000
  end

  def notifyWinner(state) do
    %{best_offer: %{price: bestPrice, buyer: token}} = state
    IO.inspect "the winner for #{state.id} is #{token}"
    winner = GenServer.call(BuyerHome, {:by_token, token})
    notifyBuyer(state, winner, :won, bestPrice)
    winner
  end

  def notifyLosers(state, winner) do
    %{best_offer: %{price: bestPrice}} = state
    notifyInterestedBut(state, winner, :lost, bestPrice)
  end

  def notifyOffer(state, offerer, newPrice) do
    notifyInterestedBut(state, offerer, :offer, newPrice)
  end

  def notifyInterestedBut(state, buyer, message, price) do
    allButOneBuyer = BuyerHome.interestedInBut(state.tags, buyer)
    Enum.each(allButOneBuyer, &(notifyBuyer(state, &1, message, price)))
  end

  #TODO rename for notifyNewAuction (or handle notifications better...)
  def notifyAll(state, message) do
    interestedBuyers = interestedBuyers(state)
    Enum.each(interestedBuyers, &(notifyBuyer(state, &1, message)))
  end

  def interestedBuyers(state) do
    BuyerHome.interestedIn(state.tags)
  end

  #TODO improve this default + if?
  def notifyBuyer(%{id: id}, buyer, message, price \\ nil) do
    notificationValue = if price, do: {id, price}, else: id
    GenServer.cast(buyer, {message, notificationValue})
  end

  def addTimeIfNeeded(state) do
    %{originalNode: originalNode, endTime: endTime} = state
    case originalNode != Node.self do
      true -> %{state | endTime: DateTime.add(endTime, 5)}
      _ -> state
    end

  end
end