defmodule Aggregator.OffersTest do
  use ExUnit.Case, async: false
  alias Aggregator.{Offers, Offer, NDCMock1, NDCMock2}

  import Mox
  import ExUnit.CaptureLog

  describe "find_cheapest_offer/3" do
    setup :set_mox_global

    setup do
      ndc_apis = Application.get_env(:aggregator, :ndc_apis)

      Application.put_env(:aggregator, :ndc_apis, %{
        "AIRLINE1" => %{code: "AIRLINE1", module: NDCMock1},
        "AIRLINE2" => %{code: "AIRLINE2", module: NDCMock2},
      })

      stub(NDCMock1, :find_cheapest_offer, fn
        # success

        "success", _, _ ->
          {:ok, %Offer{amount: 123.2, airline: "AIRLINE1"}}

        # blank

        "blank", _, _ ->
          {:ok, nil}

        # timeout

        "timeout", _, _ ->
          {:ok, %Offer{amount: 123.2, airline: "AIRLINE1"}}
      end)

      stub(NDCMock2, :find_cheapest_offer, fn
       # success

       "success", _, _  ->
          {:ok, %Offer{amount: 21.3, airline: "AIRLINE2"}}

       # blank

       "blank", _, _  ->
          {:ok, nil}

       # timeout

       "timeout", _, _  ->
          Process.sleep(10_000)
      end)

      on_exit(fn ->
        Application.put_env(:aggregator, :ndc_apis, ndc_apis)
      end)
    end

    test "finds the cheapest offer from all airlines" do
      assert %Offer{amount: 21.3, airline: "AIRLINE2"} =
               Offers.find_cheapest_offer("success", "ASD", ~D[2022-01-01])
    end

    test "when no offer was found, returns nil" do
      assert is_nil(Offers.find_cheapest_offer("blank", "ASD", ~D[2022-01-01]))
    end

    test "when a task fails by timeout, ignore the task and log the error" do
      assert capture_log([level: :error], fn ->
               assert %Offer{amount: 123.2, airline: "AIRLINE1"} =
                        Offers.find_cheapest_offer("timeout", "ASD", ~D[2022-01-01])
             end) =~ "Task at Aggregator.Offers.find_cheapest_offer/3 exited by reason: :timeout"
    end
  end

  describe "find_cheapest_offer_from_list/1" do
    test "returns the cheapest offer from list" do
      %Offer{amount: 1.2, airline: "BA"} =
        Offers.find_cheapest_from_list([
          %Offer{amount: 1.2, airline: "BA"},
          %Offer{amount: 23.1, airline: "AFKLM"}
        ])
    end

    test "returns nil if list is empty" do
      nil = Offers.find_cheapest_from_list([])
    end
  end
end
