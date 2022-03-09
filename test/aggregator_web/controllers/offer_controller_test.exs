defmodule AggregatorWeb.OfferControllerTest do
  use AggregatorWeb.ConnCase
  alias Aggregator.{Offers, Offer, NDCMock1, NDCMock2}

  import Mox

  describe "find_cheapest_offer/2" do
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
      end)

      stub(NDCMock2, :find_cheapest_offer, fn
       # success

       "success", _, _  ->
          {:ok, %Offer{amount: 21.3, airline: "AIRLINE2"}}

       # blank

       "blank", _, _  ->
          {:ok, nil}

      end)

      on_exit(fn ->
        Application.put_env(:aggregator, :ndc_apis, ndc_apis)
      end)
    end

    test "returns the cheapest offer", %{conn: conn} do
      assert %{
               "data" => %{
                 "cheapestOffer" => %{
                   "airline" => "AIRLINE2",
                   "amount" => 21.3
                 }
               }
             } =
               conn
               |> get(
                    Routes.offer_path(conn, :find_cheapest_offer),
                    %{
                      "origin" => "success",
                      "destination" => "ASD",
                      "departureDate" => "2022-01-01"
                    }
                  )
               |> json_response(200)
    end

    test "when there is no offer found, returns blank response", %{conn: conn} do
      assert %{"data" => %{"cheapestOffer" => nil}} =
               conn
               |> get(
                    Routes.offer_path(conn, :find_cheapest_offer),
                    %{
                      "origin" => "blank",
                      "destination" => "ASD",
                      "departureDate" => "2022-01-01"
                    }
                  )
               |> json_response(200)
    end

    test "when params are invalid, returns error", %{conn: conn} do
      assert %{
               "errors" => %{
                 "detail" => "Invalid params: %{\"destination\" => \"\", \"origin\" => \"123\"}"
               }
             } =
               conn
               |> get(
                    Routes.offer_path(conn, :find_cheapest_offer),
                    %{
                      "origin" => 123,
                      "destination" => nil,
                    }
                  )
               |> json_response(400)
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
