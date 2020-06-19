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

	# Basic example to handle POST requests wiht a JSON body
	post "/post" do

  	#{:ok, body, conn} = read_body(conn)
    IO.inspect conn.body_params
  	#body = Poison.decode!(body)

  	#IO.inspect(body)

  	send_resp(conn, 201, "created: #{conn.body_params.name}")

	end

	# "Default" route that will get called when no other route is matched
	match _ do

	 send_resp(conn, 404, "not found")

	end

end