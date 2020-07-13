defmodule Scenario2Tests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test
  import TestingFunctions

    test "creating buyer andy returns OK + token" do
      andy = %{name: "andy", ip: "127.0.0.1:12703", tags: ["films", "movies"]}
      conn = new_buyer(andy)
      assert conn.status == 200
    end

    test "another buyer pipo comes into play, created OK. Token of length 32 provided" do
      pipo = %{name: "pipo", ip: "127.0.0.1:12704", tags: ["football"]}
      conn = new_buyer(pipo)
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK" do
      auction_2 = %{timeout: "10", basePrice: "100", tags: ["movies"], articleJson: %{title: "2001: ASO"}}
      conn = new_auction(auction_2, "auction_2")
      assert conn.status == 200
    end

    test "buyer andy will match the auction's base price" do
      conn = new_offer_on_auction("auction_2", "andy", 100)
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_2")}"
    end

    test "buyer pipo will bid for a higher price, winning the auction" do
      conn = new_offer_on_auction("auction_2", "pipo", 200)
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_2")}"
    end
end