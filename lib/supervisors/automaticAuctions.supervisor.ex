defmodule AutomaticAuctions.Supervisor do
  use Supervisor

  def start_link do
  	options = [ strategy: :one_for_one, name: AutomaticAuctions.Supervisor ]
    Supervisor.start_link(children(), options)
  end

  def init(:ok) do
  	[]
  end

  def children() do
    [ httpRouter(), RequestHandler.Supervisor, Auction.Supervisor, Buyer.Supervisor,
      IdGenerator, Auction.Agent, Home.Supervisor ]
  end

  def httpRouter() do
    Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Http.Router, options: [port: 9001])
  end
end
