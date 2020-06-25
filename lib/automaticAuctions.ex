defmodule AutomaticAuctions do
  use Application

  def start(_type, _args) do
    port = System.argv()
      |> List.first
    AutomaticAuctions.Supervisor.start_link(port)
  end
end
