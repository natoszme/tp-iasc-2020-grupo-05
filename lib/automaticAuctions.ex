defmodule AutomaticAuctions do
  use Application

  def start(_type, _args) do
    port = System.argv()
      |> List.first
    if !port do
      IO.inspect "Please specify port after the filename"
      Process.exit(self(), :normal)
    end

    AutomaticAuctions.Supervisor.start_link(port)
  end
end
