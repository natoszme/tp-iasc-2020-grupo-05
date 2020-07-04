defmodule AutomaticAuctions do
  use Application

  def start(_type, _args) do
    port = System.get_env("PORT")
    if !port do
      IO.inspect "Env var PORT isn't set"
      Process.exit(self(), :normal)
    end

    AutomaticAuctions.Supervisor.start_link(port)
  end
end
