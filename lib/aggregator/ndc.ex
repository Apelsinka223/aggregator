defmodule Aggregator.NDC do
  @moduledoc """
  Interface to work with NDC APIs
  """

  @doc """
  List of supported airlines' codes
  """
  @spec airlines_list :: [String.t()]
  def airlines_list do
    :aggregator
    |> Application.get_env(:ndc_apis)
    |> Map.keys()
  end

  defp module(code) do
    Application.get_env(:aggregator, :ndc_apis)[code][:module]
  end

  @spec find_cheapest_offer(
          code :: String.t(),
          origin :: String.t(),
          destination :: String.t(),
          date :: Date.t()
        ) :: {:ok, Offer.t() | nil} | {:error, term()}
  def find_cheapest_offer(code, origin, destination, departure_date) do
    module(code).find_cheapest_offer(origin, destination, departure_date)
  end
end
