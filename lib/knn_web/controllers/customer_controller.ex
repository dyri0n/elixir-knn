defmodule KnnWeb.CustomerController do
  use KnnWeb, :controller
  alias Knn.Customers

  def knn_match(conn, params) do
    k = Map.get(params, "k", "5") |> String.to_integer()

    IO.puts(params)

    neighbors = Customers.find_nearest_neighbors(%{
      age: String.to_integer(params["age"]),
      purchase_amount: String.to_float(params["purchase_amount"]),
      gender: params["gender"],
      category: params["category"]
    }, k)

    json(conn, %{neighbors: neighbors})
  end
end
