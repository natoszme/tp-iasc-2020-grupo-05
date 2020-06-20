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

  #TODO may have a registry with {ip, buyer} in order to avoid notifying the offerer
  def interestedIn(tags) do
    childs = DynamicSupervisor.which_children(Buyer.Supervisor)
    Enum.filter(childs, &(childInterestedIn?(&1, tags)))
      |> Enum.map(&(elem(&1, 1)))
  end

  def childInterestedIn?(fullChild, tags) do
    child = elem(fullChild, 1)
    GenServer.call(child, {:interested?, tags})
  end
end