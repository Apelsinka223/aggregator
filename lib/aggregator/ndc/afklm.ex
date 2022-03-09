defmodule Aggregator.NDC.AFKLM do
  @moduledoc """
  British Airlines' API.
  """

  use Tesla

  alias Aggregator.{Offers, Offer}

  import SweetXml
  require Logger

  @code "AFKLM"

  def client do
    config = Application.get_env(:aggregator, :ndc_apis)[@code]

    middleware = [
      {Tesla.Middleware.BaseUrl, config[:url]},
      {Tesla.Middleware.Headers, [{"authorization", "token: " <> config[:auth_token]}]}
    ]

    Tesla.client(middleware)
  end

  def find_cheapest_offer(origin, destination, departure_date) do
    params = %{origin: origin, destination: destination, departure_date: departure_date}

    with {:ok, %{status: 200, body: response}} <- get(client(), "/findOffers/", query: params),
         offers_list = parse_offers_list(response),
         cheapest_offer = Offers.find_cheapest_from_list(offers_list) do
      {:ok, cheapest_offer}
    else
      {:ok, %{status: status, body: body}} ->
        {
          :error,
          """
          Request airline #{@code} /findOffers/ \
          failed with status: #{status} and body: #{inspect(body)}\
          """
        }
    end
  end

  # Assuming that response should be provided even if some items from response are invalid.
  # Invalid items are ignored in result, but error will be logged.
  defp parse_offers_list(response) do
    response
    |> xpath(
         ~x"//ns2:OffersGroup/ns2:CarrierOffers/ns2:Offer/ns2:TotalPrice/ns2:TotalAmount/text()"sl
       )
    |> Enum.map(fn price_string ->
      case Float.parse(price_string) do
        :error ->
          Logger.error("""
          Failed parse ns2:OffersGroup/ns2:CarrierOffers/ns2:Offer/ns2:TotalPrice/ns2:TotalAmount \
          as a float, value: #{inspect(price_string)}\
          """)

          nil

        {float, _} ->
          %Offer{amount: float, airline: @code}
      end
    end)
    |> Enum.filter(& &1)
  end
end
