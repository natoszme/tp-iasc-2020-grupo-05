defmodule IdGenerator.Agent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def last() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def increment() do
    Agent.update(__MODULE__, &(&1 + 1))
    lastId = last()
    NodeListener.syncLastId(lastId)
    lastId
  end

  def updateLastId(lastId) do
    Agent.update(__MODULE__, fn _state -> lastId end)
  end
end