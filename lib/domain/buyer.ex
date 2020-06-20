defmodule Buyer do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    IO.inspect state
    {:ok, state}
  end

  def handle_call({:interested?, auctionTags}, _sender, state) do
    ownTags = state.tags
    interested? = Enum.any?(auctionTags, &(hasTag?(&1, ownTags)))
    {:reply, interested?, state}
  end

  def hasTag?(tag, ownTags) do
    Enum.member?(ownTags, tag)
  end

  #TODO extract in another actor?
  def handle_cast({:offer, {id, price}}, state) do
    ip = state.ip
    json = Poison.encode!(%{price: price})
    IO.inspect json
    response = HTTPoison.post "#{ip}/#{id}/offers", json, [{"Content-Type", "application/json"}]
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.inspect "notification failed: not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect "notification failed: #{reason}"
    end
    {:noreply, state}
  end
end