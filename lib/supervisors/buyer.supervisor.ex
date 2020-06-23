defmodule Buyer.Supervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: Buyer.Supervisor ]
    DynamicSupervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  def createBuyer(buyerJson) do
    DynamicSupervisor.start_child(Buyer.Supervisor, {Buyer, buyerJson})
  end  
end