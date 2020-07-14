defmodule Scenario1Tests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test
  import TestingFunctions

    test "creating buyer tito returns OK + token" do
      tito = %{name: "tito", ip: "127.0.0.1:12701", tags: ["football", "maradona"]}
      conn = new_buyer(tito)
      assert conn.status == 200
    end

    test "another buyer pedro comes into play, created OK. Token of length 32 provided" do
      pedro = %{name: "pedro", ip: "127.0.0.1:12702", tags: ["football"]}
      conn = new_buyer(pedro)
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK" do
      auction_1 = %{timeout: "5", basePrice: "100", tags: ["maradona"], articleJson: %{name: "hair"}}
      #KV.Bucket.put(bucket, "auction_timeout", auctionMap.timeout) will be used if I can check the winner of an auction via testing, the test will have to wait "timeout" seconds
      conn = new_auction(auction_1, "auction_1")
      assert conn.status == 200
    end

    test "buyer tito will match the auction's base price" do
      conn = new_offer_on_auction("auction_1", "tito", 100)
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_1")}"
      # TODO route to check the (permanent) winner of an auction? or a client who knows how to receive notifications
    end
end