defmodule Aggregator.NDC.AFKLMTest do
  use ExUnit.Case, async: true

  alias Aggregator.NDC.AFKLM
  alias Aggregator.Offer

  import Tesla.Mock
  import ExUnit.CaptureLog

  describe "find_cheapest_offer/3" do
    setup do
      mock(fn
        # success

        %{
          method: :get,
          url: "https://example.com/afklm/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "success"},
          headers: [{"authorization", "token: afklm_token"}],
        } ->
          %Tesla.Env{
            status: 200,
            body: File.read!(Path.join(File.cwd!(), "test/fixtures/afklm_response_sample.xml"))
          }

        # invalid body

        %{
          method: :get,
          url: "https://example.com/afklm/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "invalid"}
        } ->
          %Tesla.Env{
            status: 200,
            body:
              File.read!(Path.join(File.cwd!(), "test/fixtures/afklm_invalid_response_sample.xml"))
          }

        # blank

        %{
          method: :get,
          url: "https://example.com/afklm/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "blank"}
        } ->
          %Tesla.Env{
            status: 200,
            body:
              File.read!(Path.join(File.cwd!(), "test/fixtures/afklm_blank_response_sample.xml"))
          }

        # error

        %{
          method: :get,
          url: "https://example.com/afklm/findOffers/",
          query: %{departure_date: ~D[2022-01-01], destination: "ASD", origin: "not_found"}
        } ->
          %Tesla.Env{status: 404, body: "Not Found"}
      end)
    end

    test "parses response and returns the cheapest offer" do
      assert {:ok, %Offer{amount: 199.29, airline: "AFKLM"}} =
               AFKLM.find_cheapest_offer("success", "ASD", ~D[2022-01-01])
    end

    test "when no offer was found, returns nil" do
      assert {:ok, nil} = AFKLM.find_cheapest_offer("blank", "ASD", ~D[2022-01-01])
    end

    test "on invalid body, ignores invalid entities and logs error" do
      assert capture_log([level: :error], fn ->
               assert {:ok, %Offer{amount: 232.29, airline: "AFKLM"}} =
                        AFKLM.find_cheapest_offer("invalid", "ASD", ~D[2022-01-01])
             end) =~
               """
               Failed parse ns2:OffersGroup/ns2:CarrierOffers/ns2:Offer/ns2:TotalPrice/\
               ns2:TotalAmount as a float, value: \"INVALID\"
               """
    end

    test "when status code is not 200, returns error" do
      assert {
               :error,
               "Request airline AFKLM /findOffers/ failed with status: 404 and body: \"Not Found\""
             } = AFKLM.find_cheapest_offer("not_found", "ASD", ~D[2022-01-01])
    end
  end
end
