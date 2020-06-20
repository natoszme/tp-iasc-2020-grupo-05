defmodule Buyer do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    IO.inspect state
    {:ok, state}
  end

  def handle_call({:interested?, auctionTags}, _sender, state) do
    IO.puts("about to check if interested in tags")
    ownTags = state.tags
    IO.inspect ownTags
    interested? = Enum.any?(auctionTags, &(hasTag?(&1, ownTags)))
    {:reply, interested?, state}
  end

  def hasTag?(tag, ownTags) do
    Enum.member?(ownTags, tag)
  end

  # def handle_cast({:parse_and_download}, {line, target_directory}) do
  #   regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
  #     Regex.scan(regexp, line)
  #       |> links_from_regex()
  #       |> fetch_links(target_directory)
  #   {:noreply, {line, target_directory}}
  # end
end