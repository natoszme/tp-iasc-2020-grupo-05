defmodule Buyer.Supervisor do
  use Horde.DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Buyer.Supervisor ]
    Horde.DynamicSupervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  def createBuyer(buyerJson) do
    Horde.DynamicSupervisor.start_child(Buyer.Supervisor, {Buyer, buyerJson})
  end  
end