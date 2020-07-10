# Create a new test module (test case) and use "ExUnit.Case".
defmodule AuctionsEndpointsTests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test
  @opts Http.Router.init([])

  setup_all do # temporal storage
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

    test "creating buyer A returns OK + token", %{bucket: bucket} do
      tito = %{name: "tito", ip: "127.0.0.1", tags: "[football, maradona]"}
      conn = conn(:post, "http://localhost:9001/buyers", tito) |> Http.Router.call(@opts)
      assert conn.status == 200
      KV.Bucket.put(bucket, "tokenA", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token"))
    end

    test "creating a schemaless buyer shouldn't be allowed", %{bucket: bucket} do
      # if we don't validate a basic schema, :tags won't be found when trying to notify
      conn = conn(:post, "http://localhost:9001/buyers", %{}) |> Http.Router.call(@opts)
      assert conn.status == 400 # bad request
    end

    test "another buyer B comes into play, created OK" do
      pedro = %{name: "pedro", ip: "127.0.0.2", tags: "[football]"}
      conn = conn(:post, "http://localhost:9001/buyers", pedro) |> Http.Router.call(@opts)
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK", %{bucket: bucket} do
      auction = %{basePrice: "200", tags: ["maradona"], timeout: "5", articleJson: %{name: "hair"}}
      KV.Bucket.put(bucket, "auction_timeout", auction.timeout)
      conn = conn(:post, "http://localhost:9001/bids", auction) |> Http.Router.call(@opts)
      assert conn.status == 200
      # por que esto tira error? hay un mal parseo del map en :timeout, intente de todo pero no anda :(, la otra es pasar un string multiple con """ u 
      # KV.Bucket.put(bucket, "auctionId", Poison.Parser.parse(conn.resp_body) // TODO descomentar cuando el test ande
    end

    test "buyer A will match the auction's base price and win, given the timeout", %{bucket: bucket} do
      conn = conn(:post, "http://localhost:9001/bids/#{KV.Bucket.get(bucket, "auctionId")}/offer?token=#{KV.Bucket.get(bucket, "tokenA")}", %{price: 200}) |> Http.Router.call(@opts)
      assert true
      # route to check the (permanent) winner of an auction? or a client who knows how to receive notifications
    end

end