defmodule Home.Supervisor do
  use Supervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Home.Supervisor ]
    Supervisor.start_link(children(), options)
  end

  def init(:ok) do
    []
  end

  def children() do
    [ AuctionHome ]
  end
end
