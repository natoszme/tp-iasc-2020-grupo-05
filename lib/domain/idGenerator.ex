#TODO should be an agent
defmodule IdGenerator do
  use GenServer

  def start_link(_opts) do
    last = IdGenerator.Agent.last()
    Singleton.start_child(__MODULE__, last, IdGenerator)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:next, _sender, _state) do
    next = IdGenerator.Agent.increment()
    {:reply, next, next}
  end
end