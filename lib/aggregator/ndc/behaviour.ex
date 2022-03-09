defmodule Aggregator.NDC.Behaviour do
  @moduledoc """
  Behaviour of the NDC API Modules
  """

  alias Aggregator.NDC.Offer

  @doc """
  Calls NDC API for the offers list by passed parameters and returns the cheapest offer.

  ## Parameters

    - origin (String) - airport code of the origin
    - destination (String) - airport code of the destination
    - departure_date (Date) - departure date

  ## Examples

    iex> find_cheapest_offer("BER", "LHR", ~D[2019-07-17])
    {:ok, %Offer{amount: 55.19, airline: "BA"}}

  """
  @callback find_cheapest_offer(
              origin :: String.t(),
              destination :: String.t(),
              departure_date :: Date.t()
            ) :: {:ok, Offer.t() | nil} | {:error, term()}
end
