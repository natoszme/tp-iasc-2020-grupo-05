defmodule Http.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

	plug(Plug.Logger, log: :debug)

	plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: {Poison, :decode!, [[keys: :atoms]]})

	plug(:dispatch)

  forward "/bids", to: Bids.Router
  forward "/buyers", to: Buyers.Router

	# "Default" route that will get called when no other route is matched
	match _ do

	 send_resp(conn, 404, "not found")

	end

end