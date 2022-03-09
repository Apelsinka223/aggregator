defmodule AggregatorWeb.Router do
  use AggregatorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AggregatorWeb do
    pipe_through :api

    get "/findCheapestOffer", OfferController, :find_cheapest_offer
  end
end
