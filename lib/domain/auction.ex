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

  #TODO look for the interested buyers (for now, using which_children of Buyer.Supervisor)
  #TODO may be a cast
  def handle_call({:create_offer, offerJson}, _sender, state) do
    IO.inspect offerJson.price
    interestedBuyers = Buyer.Supervisor.interestedIn(state.tags)
    IO.inspect interestedBuyers
    {:reply, state, state}
  end

  def handle_info(:timeout, state) do
    IO.puts("about to end auction")

    Process.send_after(self(), :accident, 2000)

    {:stop, :normal, state}
  end

  def handle_info(:die, _state) do
    IO.puts("about to die")

    {:stop, :dead}
  end

  #TODO deconstruct map in param?
  def timeToTimeout(state) do
    Time.diff(state.endTime, Time.utc_now()) * 1000
  end
end