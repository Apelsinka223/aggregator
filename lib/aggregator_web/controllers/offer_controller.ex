defmodule AggregatorWeb.OfferController do
  use AggregatorWeb, :controller
  alias Aggregator.Offers

  action_fallback AggregatorWeb.FallbackController

  def find_cheapest_offer(conn, params) do
    with {:ok, params} <- parse_find_cheapest_offer_params(params),
         offer =
           Offers.find_cheapest_offer(
             params["origin"],
             params["destination"],
             params["departureDate"]
           ) do
      render(conn, "cheapest_offer.json", offer: offer)
    end
  end

  defp parse_find_cheapest_offer_params(params) do
    with true <- is_binary(params["origin"]),
         true <- is_binary(params["destination"]),
         true <- is_binary(params["departureDate"]),
         {:ok, date} <- Date.from_iso8601(params["departureDate"]) do
      {:ok, Map.put(params, "departureDate", date)}
    else
      _ ->
        {:error, :invalid_params, params}
    end
  end
end
