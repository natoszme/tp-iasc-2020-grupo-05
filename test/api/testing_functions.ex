defmodule TestingFunctions do
    use Plug.Test    
    def build_and_get_response(relative_path, data_as_map) do
        conn(:post, "http://localhost:#{System.get_env("PORT")}#{relative_path}", Poison.encode!(data_as_map)) |> put_req_header("content-type","application/json") |> Http.Router.call(Http.Router.init([]))
    end

    def new_buyer(buyer_data) do # buyer data must be a map containing ip, name, tags
        conn = build_and_get_response("/buyers", buyer_data)
        KV.Bucket.put(buyer_data.name, Poison.Parser.parse(conn.resp_body) |> elem(1) |> Map.get("token")) # for future use
        conn
    end

    def new_auction(auction_data, auction_name) do # auction_data must be a map containing timeout, tags, articleJson, basePrice
        conn = build_and_get_response("/bids", auction_data)
        KV.Bucket.put(auction_name, conn.resp_body |> String.split(" ") |> Enum.at(-1)) # get auction number or id, last word of the resp string
        conn
    end

    def new_offer_on_auction(auction_name, buyer_name, new_price) do
        auction_id = get_auction_id(auction_name)    
        buyer_token = get_buyer_token(buyer_name)
        IO.inspect("Token #{buyer_token} makes offer on auction ##{auction_id}")
        build_and_get_response("/bids/#{auction_id}/offer?token=#{buyer_token}", %{price: new_price})
    end

    def get_auction_id(auction_name) do
        KV.Bucket.get(auction_name)
    end

    def get_buyer_token(buyer_name) do
        KV.Bucket.get(buyer_name)
    end

    def cancel_auction(auction_name) do
        build_and_get_response("/bids/#{get_auction_id(auction_name)}/cancel", %{})
    end
end