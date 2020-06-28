defmodule BuyerRegistry do
  use Horde.Registry

  def init(options) do
    {:ok, Keyword.put(options, :members, get_members())}
  end

  def start do
    Horde.Registry.start_link(keys: :unique, name: Buyer.Registry)
  end

  #TODO reuse between auction registry
  def buyerByToken(token) do
    Horde.Registry.lookup(Buyer.Registry, token)
      |> List.first
  end

  defp get_members() do
    [Node.self() | Node.list()]
      |> Enum.map(fn node -> {Buyer.Registry, node} end)
  end
end