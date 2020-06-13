defmodule AutomaticAuctions do
  use Application

  def start(_type, _args) do
    AutomaticAuctions.Supervisor.start_link
  end
 
  def fetch() do
    #GenServer.cast(ImageFinder.Worker, {:fetch, source_file, target_directory})
  end
end
