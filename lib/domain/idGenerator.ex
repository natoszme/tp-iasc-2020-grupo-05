#TODO should be an agent
#TODO should be global and supervised using horde
defmodule IdGenerator do
  use GenServer

  def start_link(_opts) do
    Singleton.start_child(__MODULE__, 0, IdGenerator)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:next, _sender, actual) do
    actual = actual + 1
    {:reply, actual, actual}
  end
end