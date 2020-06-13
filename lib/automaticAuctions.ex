defmodule AutomaticAuctions do
  use Application

  def start(_type, _args) do
    AutomaticAuctions.Supervisor.start_link
  end
end
