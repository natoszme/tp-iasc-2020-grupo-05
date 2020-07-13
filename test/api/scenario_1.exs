# Create a new test module (test case) and use "ExUnit.Case".
defmodule Scenario1Tests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test

  def build_and_get_response(relative_path, dataAsMap) do
    conn(:post, "http://localhost:9001#{relative_path}", Poison.encode!(dataAsMap)) |> put_req_header("content-type","application/json") |> Http.Router.call(Http.Router.init([]))
  end

  setup_all do # temporal storage
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

    test "creating buyer A returns OK + token", %{bucket: bucket} do
      tito = %{name: "tito", ip: "127.0.0.1", tags: ["football", "maradona"]}
      conn = build_and_get_response("/buyers", tito)
      KV.Bucket.put(bucket, "tokenA", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
      assert conn.status == 200
    end

    test "another buyer B comes into play, created OK. Token of length 32 provided" do
      pedro = %{name: "pedro", ip: "127.0.0.2", tags: ["football"]}
      conn = build_and_get_response("/buyers", pedro)
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK", %{bucket: bucket} do
      auctionMap = %{timeout: "5", basePrice: "200", tags: ["maradona"], articleJson: %{name: "hair"}}
      KV.Bucket.put(bucket, "auction_timeout", auctionMap.timeout)
      conn = build_and_get_response("/bids", auctionMap)
      KV.Bucket.put(bucket, "auctionId", conn.resp_body |> String.split(" ") |> Enum.at(-1))
      assert conn.status == 200
    end

    test "buyer A will match the auction's base price", %{bucket: bucket} do
      conn = build_and_get_response("/bids/#{KV.Bucket.get(bucket, "auctionId")}/offer?token=#{KV.Bucket.get(bucket, "tokenA")}", %{price: 200})
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{KV.Bucket.get(bucket, "auctionId")}"
      # TODO route to check the (permanent) winner of an auction? or a client who knows how to receive notifications
    end
end