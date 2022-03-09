defmodule AggregatorWeb.FallbackController do
  use AggregatorWeb, :controller
  alias AggregatorWeb.ErrorView

  def call(conn, {:error, :invalid_params, params}) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render(:"400", params: params)
  end
end
