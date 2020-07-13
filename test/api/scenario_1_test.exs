defmodule Scenario1Tests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test
  import TestingFunctions

  setup_all do # temporal storage
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

    test "creating buyer A returns OK + token", %{bucket: bucket} do
      tito = %{name: "tito", ip: "127.0.0.1:12701", tags: ["football", "maradona"]}
      conn = new_buyer(tito)
      KV.Bucket.put(bucket, "token_a", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
      assert conn.status == 200
    end

    test "another buyer B comes into play, created OK. Token of length 32 provided" do
      pedro = %{name: "pedro", ip: "127.0.0.1:12702", tags: ["football"]}
      conn = new_buyer(pedro)
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK", %{bucket: bucket} do
      auction_1 = %{timeout: "5", basePrice: "100", tags: ["maradona"], articleJson: %{name: "hair"}}
      #KV.Bucket.put(bucket, "auction_timeout", auctionMap.timeout) will be used if I can check the winner of an auction via testing, the test will have to wait "timeout" seconds
      conn = new_auction(auction_1)
      KV.Bucket.put(bucket, "auction_1_id", conn.resp_body |> String.split(" ") |> Enum.at(-1)) # get auction number or id, last word of the resp string
      assert conn.status == 200
    end

    test "buyer A will match the auction's base price", %{bucket: bucket} do
      conn = new_offer_on_auction(KV.Bucket.get(bucket, "auction_1_id"), KV.Bucket.get(bucket, "token_a"), %{price: 100})
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{KV.Bucket.get(bucket, "auction_1_id")}"
      IO.inspect("WINNER for auction #{KV.Bucket.get(bucket, "auction_1_id")} should be token #{KV.Bucket.get(bucket, "token_a")}")
      # TODO route to check the (permanent) winner of an auction? or a client who knows how to receive notifications
    end
end