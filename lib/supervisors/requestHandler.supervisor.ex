defmodule RequestHandler.Supervisor do
  #is this ok? Task.Supervisor here doesn't work
  use Supervisor

  def start_link(_opts) do
    options = [ strategy: :one_for_one, name: RequestHandler.Supervisor ]
    Task.Supervisor.start_link(options)
  end

  def init(:ok) do
    []
  end

  def new(module, function, args) do
    Task.Supervisor.async(RequestHandler.Supervisor, module, function, [args])
  end
end