defmodule RequestHandler.Supervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: RequestHandler.Supervisor ]
    DynamicSupervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  def new(module) do
    {:ok, requestHandler} = DynamicSupervisor.start_child(RequestHandler.Supervisor, module)
    requestHandler
  end
end