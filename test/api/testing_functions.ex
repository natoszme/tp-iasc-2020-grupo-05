defmodule TestingFunctions do
    use Plug.Test    
    def build_and_get_response(relative_path, data_as_map) do
        conn(:post, "http://localhost:#{System.get_env("PORT")}#{relative_path}", Poison.encode!(data_as_map)) |> put_req_header("content-type","application/json") |> Http.Router.call(Http.Router.init([]))
    end

    def new_buyer(buyer_data) do # buyer data must be a map containing ip, name, tags
        build_and_get_response("/buyers", buyer_data)
    end

    def new_auction(auction_data) do # auction_data must be a map containing timeout, tags, articleJson, basePrice
        build_and_get_response("/bids", auction_data)
    end

    def new_offer_on_auction(auction_id, buyer_token, new_price) do # auction_id and buyer_token are strings, new_price is a map with a key :price
        build_and_get_response("/bids/#{auction_id}/offer?token=#{buyer_token}", new_price)
    end

    def cancel_auction(auction_id) do # auction_id must be a string id
        build_and_get_response("/bids/#{auction_id}/cancel", %{})
    end
end