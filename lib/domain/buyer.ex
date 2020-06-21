defmodule Buyer do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    IO.inspect state
    #TODO need to change registry to duplicate keys?
    withoutPort = Enum.at(String.split(state.ip, ":"), 0)
    Registry.register(BuyerRegistry, withoutPort, {})
    {:ok, state}
  end

  def handle_call({:interested?, auctionTags}, _sender, state) do
    ownTags = state.tags
    interested? = Enum.any?(auctionTags, &(hasTag?(&1, ownTags)))
    {:reply, interested?, state}
  end

  def handle_call(:ip, _sender, state) do
    {:reply, state.ip, state}
  end

  def hasTag?(tag, ownTags) do
    Enum.member?(ownTags, tag)
  end

  #TODO what if it receives the ip and knows if notify or not?!
  def handle_cast({:offer, {id, price}}, state) do
    notifyClient(state, "offers", id, price)
    {:noreply, state}
  end

  def handle_cast({:won, {id, winnerPrice}}, state) do
    notifyClient(state, "won", id, winnerPrice)
    {:noreply, state}
  end

  def handle_cast({:lost, {id, winnerPrice}}, state) do
    notifyClient(state, "lost", id, winnerPrice)
    {:noreply, state}
  end

  #TODO extract in another actor?
  def notifyClient(%{ip: ip}, resource, id, price) do
    IO.inspect "about to notify #{ip}/#{id}/#{resource} with price #{price}"
    json = Poison.encode!(%{price: price})
    response = HTTPoison.post "#{ip}/#{id}/#{resource}", json, [{"Content-Type", "application/json"}]
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.inspect "notification failed: not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect "notification failed: #{reason}"
    end
  end
end