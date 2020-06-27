defmodule AuctionRegistry do
  use Horde.Registry

  def init(options) do
    {:ok, Keyword.put(options, :members, get_members())}
  end

  def start do
    Horde.Registry.start_link(keys: :unique, name: AuctionRegistry)
  end

  def auctionById(id) do
    Horde.Registry.lookup(AuctionRegistry, String.to_integer(id))
      |> List.first
  end

  defp get_members() do
    [Node.self() | Node.list()]
      |> Enum.map(fn node -> {AuctionRegistry, node} end)
  end
end