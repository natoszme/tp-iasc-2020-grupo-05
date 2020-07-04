defmodule AutomaticAuctions.Supervisor do
  use Supervisor

  def start_link(port) do
  	options = [ strategy: :one_for_one, name: AutomaticAuctions.Supervisor ]
    Supervisor.start_link(children(port), options)
  end

  def init(:ok) do
  	[]
  end

  def children(port) do
    [ httpRouter(port), clusterDefinition(), RequestHandler.Supervisor, Auction.Supervisor, Buyer.Supervisor,
      IdGenerator.Agent, IdGenerator, Auction.Agent, Home.Supervisor, taskSupervisor(), NodeListener ]
  end

  def httpRouter(port) do
    router = Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Http.Router, options: [port: String.to_integer(port)])
    IO.inspect "Listening in port #{port}"
    router
  end

  def clusterDefinition do
    topologies = [
      automaticAuctions: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    {Cluster.Supervisor, [topologies, [name: AutomaticAuctions.Cluster.Supervisor]]}
  end

  def taskSupervisor do
    {Task.Supervisor, name: AgentReplicator.Supervisor}
  end
end
