defmodule NodeListener do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: NodeListener)
  end

  def init(_) do
    :net_kernel.monitor_nodes(true, node_type: :visible)
    {:ok, nil}
  end

  #TODO this can be improved to only add the new node
  def handle_info({:nodeup, _node, _node_type}, state) do
    set_all_members()
    sync_auction_agent()
    sync_idGenerator_agent()
    {:noreply, state}
  end

  #TODO this can be improved to only remove the dead node
  def handle_info({:nodedown, _node, _node_type}, state) do
    set_all_members()
    {:noreply, state}
  end

  def set_all_members() do
    set_members(Auction.Supervisor)
    set_members(Auction.Registry)
    set_members(Buyer.Supervisor)
    set_members(Buyer.Registry)
  end

  defp set_members(name) do
    members =
    [Node.self() | Node.list()]
      |> Enum.map(fn node -> {name, node} end)
    :ok = Horde.Cluster.set_members(name, members)
  end

  #TODO improve this crap
  #TODO necessary since when the node is up, its AgentReplicator.Supervisor may have not started yet
  #TODO maybe delegatin in another actor that retries?
  def sync_auction_agent do
    Process.sleep(1000)
    Node.list()
      |> Enum.each(fn node -> sync_agent_with_node(node) end)
  end

  def sync_idGenerator_agent do
    Process.sleep(1000)
    Node.list()
      |> Enum.each(fn node -> sync_idGenerator_with_node(node) end)
  end

  def sync_agent_with_node(node) do
    IO.inspect "about to sync Auction.Agent with #{node}"
    stateToSync = Auction.Agent.allState()
    task = Task.Supervisor.async {AgentReplicator.Supervisor, node}, fn ->
      Auction.Agent.syncState(stateToSync)
    end

    Task.await(task)
  end

  def sync_idGenerator_with_node(node) do
    IO.inspect "about to sync IdGenerator.Agent with #{node}"
    lastId = IdGenerator.Agent.last()
    task = Task.Supervisor.async {AgentReplicator.Supervisor, node}, fn ->
      IdGenerator.Agent.updateLastId(lastId)
    end

    Task.await(task)
  end

  def syncOffer(id, offer) do
    Node.list()
      |> Enum.each(fn node -> sync_auction_with_node(node, id, offer) end)
  end

  def syncLastId(lastId) do
    Node.list()
      |> Enum.each(fn node -> sync_last_id_with_node(node, lastId) end)
  end

  #TODO avoid repeating
  def sync_auction_with_node(node, id, offer) do
    IO.inspect "about to sync auction with #{node}"
    task = Task.Supervisor.async {AgentReplicator.Supervisor, node}, fn ->
      Auction.Agent.syncOffer({id, offer})
    end

    Task.await(task)
  end

  def sync_last_id_with_node(node, lastId) do
    IO.inspect "about to sync lastId with #{node}"
    task = Task.Supervisor.async {AgentReplicator.Supervisor, node}, fn ->
      IdGenerator.Agent.updateLastId(lastId)
    end

    Task.await(task)
  end
end