defmodule Scenario3Tests do
    # "async: true" -> tests are run concurrently
    use ExUnit.Case, async: false
    use Plug.Test
    import TestingFunctions

    describe "scenario 3" do
      test "creating buyer hugo returns OK + token" do
        hugo = %{name: "hugo", ip: "127.0.0.1:12705", tags: ["currency"]}
        conn = new_buyer(hugo)
        assert conn.status == 200
      end
  
      test "another buyer rafa comes into play, created OK. Token of length 32 provided" do
        rafa = %{name: "rafa", ip: "127.0.0.1:12706", tags: ["currency"]}
        conn = new_buyer(rafa)
        assert conn.status == 200
      end
  
      test "creating an auction returns OK" do
        auction_3 = %{timeout: "10", basePrice: "50", tags: ["currency"], articleJson: %{name: "first dollar ever used"}}
        conn = new_auction(auction_3, "auction_3")
        assert conn.status == 200
      end
  
      test "buyer hugo will match the auction's base price" do
        conn = new_offer_on_auction("auction_3", "hugo", 50)
        assert conn.status == 200
        assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_3")}"
      end

      test "seller cancels auction and therefore no one wins" do
        conn = cancel_auction("auction_3")
        assert conn.status == 200
        assert conn.resp_body == "cancelled auction #{get_auction_id("auction_3")}"
      end
    end


    describe "scenario 4" do
      test "a new auction is created" do
        auction_4 = %{timeout: "10", basePrice: "400", tags: ["chemical"], articleJson: %{name: "1m long stick of uranium"}}
        conn = new_auction(auction_4, "auction_4")
        assert conn.status == 200
      end

      test "buyer hugo will place an offer matching the base price" do
        conn = new_offer_on_auction("auction_4", "hugo", 400)
        assert conn.status == 200
        assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_4")}"
        end

      test "buyer totally_not_us registers out of nowhere and makes an offer" do
        totally_not_us = %{name: "totally_not_us", ip: "127.0.0.1:12707", tags: ["chemical"]}
        buyer_conn = new_buyer(totally_not_us)
        conn = new_offer_on_auction("auction_4", "totally_not_us", 500)
        assert conn.status == 200
        assert conn.resp_body == "created offer for auction ##{get_auction_id("auction_4")}"
      end
    end
  end