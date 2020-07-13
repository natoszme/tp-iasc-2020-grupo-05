defmodule Scenario3Tests do
    # "async: true" -> tests are run concurrently
    use ExUnit.Case, async: false
    use Plug.Test
    import TestingFunctions
  
    setup_all do # temporal storage
      {:ok, bucket} = KV.Bucket.start_link([])
      %{bucket: bucket}
    end

      test "creating buyer E returns OK + token", %{bucket: bucket} do
        hugo = %{name: "hugo", ip: "127.0.0.1:12705", tags: ["currency"]}
        conn = new_buyer(hugo)
        KV.Bucket.put(bucket, "token_e", Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
        assert conn.status == 200
      end
  
      test "another buyer F comes into play, created OK. Token of length 32 provided" do
        rafa = %{name: "rafa", ip: "127.0.0.1:12706", tags: ["currency"]}
        conn = new_buyer(rafa)
        assert conn.status == 200
        assert Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token") |> String.length |> Kernel.==(32)
      end
  
      test "creating an auction returns OK", %{bucket: bucket} do
        auction_3 = %{timeout: "10", basePrice: "50", tags: ["currency"], articleJson: %{name: "first dollar ever used"}}
        #KV.Bucket.put(bucket, "auction_timeout", auctionMap.timeout) will be used if I can check the winner of an auction via testing, the test will have to wait "timeout" seconds
        conn = new_auction(auction_3)
        KV.Bucket.put(bucket, "auction_3_id", conn.resp_body |> String.split(" ") |> Enum.at(-1)) # get auction number or id, last word of the resp string
        assert conn.status == 200
      end
  
      test "buyer E will match the auction's base price", %{bucket: bucket} do
        conn = new_offer_on_auction(KV.Bucket.get(bucket, "auction_3_id"), KV.Bucket.get(bucket, "token_e"), %{price: 50})
        assert conn.status == 200
        assert conn.resp_body == "created offer for auction ##{KV.Bucket.get(bucket, "auction_3_id")}"
      end

      test "seller cancels auction and therefore no one wins", %{bucket: bucket} do
        id = KV.Bucket.get(bucket, "auction_3_id")
        conn = cancel_auction(id)
        assert conn.status == 200
        assert conn.resp_body == "cancelled auction #{id}"
      end
  end