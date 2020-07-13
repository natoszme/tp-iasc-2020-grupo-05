defmodule Scenario2Tests do
  # "async: true" -> tests are run concurrently
  use ExUnit.Case, async: false
  use Plug.Test
  import TestingFunctions

  setup_all do # temporal storage
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

    test "creating buyer C returns OK + token", %{bucket: bucket} do
      andy = %{name: "andy", ip: "127.0.0.1:12703", tags: ["films", "movies"]}
      conn = new_buyer(andy)
      KV.Bucket.put(bucket, "token_c", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
      assert conn.status == 200
    end

    test "another buyer D comes into play, created OK. Token of length 32 provided", %{bucket: bucket} do
      pipo = %{name: "pipo", ip: "127.0.0.1:12704", tags: ["football"]}
      conn = new_buyer(pipo)
      KV.Bucket.put(bucket, "token_d", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
      assert conn.status == 200
      assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
    end

    test "creating an auction returns OK", %{bucket: bucket} do
      auction_2 = %{timeout: "10", basePrice: "100", tags: ["movies"], articleJson: %{title: "2001: ASO"}}
      #KV.Bucket.put(bucket, "auction_timeout", auctionMap.timeout)
      conn = new_auction(auction_2)
      KV.Bucket.put(bucket, "auction_2_id", conn.resp_body |> String.split(" ") |> Enum.at(-1)) # get auction number or id, last word of the resp string
      assert conn.status == 200
    end

    test "buyer C will match the auction's base price", %{bucket: bucket} do
      conn = new_offer_on_auction(KV.Bucket.get(bucket, "auction_2_id"), KV.Bucket.get(bucket, "token_c"), %{price: 100})
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{KV.Bucket.get(bucket, "auction_2_id")}"
      IO.inspect("First offer is made by #{KV.Bucket.get(bucket, "token_c")}")
    end

    test "buyer D will bid for a higher price, winning the auction", %{bucket: bucket} do
      conn = new_offer_on_auction(KV.Bucket.get(bucket, "auction_2_id"), KV.Bucket.get(bucket, "token_d"), %{price: 200})
      assert conn.status == 200
      assert conn.resp_body == "created offer for auction ##{KV.Bucket.get(bucket, "auction_2_id")}"
      IO.inspect("WINNER for auction #{KV.Bucket.get(bucket, "auction_2_id")} should be token #{KV.Bucket.get(bucket, "token_d")}")
    end
end