defmodule Buyer do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    IO.inspect state
    {:ok, state}
  end

  def handle_cast({:parse_and_download}, {line, target_directory}) do
    # regexp = ~r/http(s?)\:.*?\.(png|jpg|gif)/
    #   Regex.scan(regexp, line)
    #     |> links_from_regex()
    #     |> fetch_links(target_directory)
    # {:noreply, {line, target_directory}}
  end
end