defmodule IdGenerator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, 0, name: IdGenerator)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:next, _sender, actual) do
    actual = actual + 1
    {:reply, actual, actual}
  end
end