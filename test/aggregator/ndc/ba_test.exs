defmodule Aggregator.NDC.BATest do
  use ExUnit.Case, async: true

  alias Aggregator.NDC.BA
  alias Aggregator.Offer

  import Tesla.Mock
  import ExUnit.CaptureLog

  describe "find_cheapest_offer/3" do
    setup do
      mock(fn
        # success

        %{
          method: :get,
          url: "https://example.com/ba/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "success"},
          headers: [{"authorization", "token: ba_token"}],
        } ->
          %Tesla.Env{
            status: 200,
            body: File.read!(Path.join(File.cwd!(), "test/fixtures/ba_response_sample.xml"))
          }

        # invalid body

        %{
          method: :get,
          url: "https://example.com/ba/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "invalid"}
        } ->
          %Tesla.Env{
            status: 200,
            body:
              File.read!(Path.join(File.cwd!(), "test/fixtures/ba_invalid_response_sample.xml"))
          }

        # blank

        %{
          method: :get,
          url: "https://example.com/ba/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "blank"}
        } ->
          %Tesla.Env{
            status: 200,
            body:
              File.read!(Path.join(File.cwd!(), "test/fixtures/ba_blank_response_sample.xml"))
          }

        # error

        %{
          method: :get,
          url: "https://example.com/ba/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "not_found"}
        } ->
          %Tesla.Env{status: 404, body: "Not Found"}
      end)
    end

    test "parses response and returns the cheapest offer" do
      assert {:ok, %Offer{amount: 132.38, airline: "BA"}} =
               BA.find_cheapest_offer("success", "ASD", ~D[2022-01-01])
    end

    test "when no offer was found, returns nil" do
      assert {:ok, nil} = BA.find_cheapest_offer("blank", "ASD", ~D[2022-01-01])
    end

    test "on invalid body, ignores invalid entities and logs error" do
      assert capture_log([level: :error], fn ->
               assert {:ok, %Offer{amount: 132.38, airline: "BA"}} =
                        BA.find_cheapest_offer("invalid", "ASD", ~D[2022-01-01])
             end) =~
               """
               Failed parse AirlineOffers/AirlineOffer/TotalPrice/SimpleCurrencyPrice as a float, \
               value: \"INVALID\"
               """
    end

    test "when status code is not 200, returns error" do
      assert {
               :error,
               "Request airline BA /findOffers/ failed with status: 404 and body: \"Not Found\""
             } = BA.find_cheapest_offer("not_found", "ASD", ~D[2022-01-01])
    end
  end
end
