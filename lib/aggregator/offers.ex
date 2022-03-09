defmodule Aggregator.Offers do
  @moduledoc false

  require Logger

  alias Aggregator.{NDC, Offer, TaskSupervisor}

  @spec find_cheapest_offer(
          origin :: String.t(),
          destination :: String.t(),
          date :: Date.t()
        ) :: Offer.t() | nil
  def find_cheapest_offer(origin, destination, departure_date) do
    TaskSupervisor
    |> Task.Supervisor.async_stream(
      NDC.airlines_list(),
      fn code ->
        NDC.find_cheapest_offer(code, origin, destination, departure_date)
      end,
      on_timeout: :kill_task
    )
    |> Enum.reduce([], fn
      {:ok, {:ok, nil}}, acc ->
        acc

      {:ok, {:ok, offer}}, acc ->
        [offer | acc]

      {:ok, {:error, reason}}, acc ->
        Logger.error(reason)
        acc

      {:exit, reason}, acc ->
        Logger.error(
          "Task at Aggregator.Offers.find_cheapest_offer/3 exited by reason: #{inspect(reason)}"
        )

        acc
    end)
    |> find_cheapest_from_list()
  end

  def find_cheapest_from_list([]), do: nil

  def find_cheapest_from_list(offer_list) do
    Enum.min_by(offer_list, & &1.amount)
  end
end
