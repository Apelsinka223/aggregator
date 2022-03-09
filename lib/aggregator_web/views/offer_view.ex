defmodule AggregatorWeb.OfferView do
  use AggregatorWeb, :view

  def render("cheapest_offer.json", %{offer: nil}) do
    %{data: %{cheapestOffer: nil}}
  end

  def render("cheapest_offer.json", %{offer: offer}) do
    %{
      data: %{
        cheapestOffer: %{
          amount: offer.amount,
          airline: offer.airline
        }
      }
    }
  end
end
