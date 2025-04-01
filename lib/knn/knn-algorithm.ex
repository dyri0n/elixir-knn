defmodule Knn.Algorithm do
  alias Knn.Predictions
  alias Knn.{Repo, Customer}

  def predict_probability(input_data, k \\ 10) do
    training_data = Predictions.get_training_data()
    encoded_input = Predictions.encode_row(input_data)

    distances =
      training_data
      |> Enum.map(fn train_row ->
        {train_row, distance(encoded_input, Map.drop(train_row, [:id]))}
      end)
      |> Enum.sort_by(fn {_row, dist} -> dist end)
      |> Enum.take(k)

    calculate_probability(distances)
  end

  defp distance(input, train) do
    keys = Map.keys(input)

    squared_diff =
      Enum.map(keys, fn key ->
        a = input[key]
        b = train[key]
        (a - b) ** 2
      end)

    Enum.sum(squared_diff) |> :math.sqrt()
  end

  import Ecto.Query

  import Ecto.Query

  defp calculate_probability(neighbors) do
    # Extraer los customer_id de los vecinos similares
    customer_ids = Enum.map(neighbors, fn {row, _dist} -> row[:customer_id] end)

    # Obtener la fecha hace un mes desde hoy
    one_month_ago = Date.add(Date.utc_today(), -30)

    query =
      from c in Customer,
        where: c.customer_id in ^customer_ids and c.purchase_date >= ^one_month_ago,
        select: count(c.customer_id)

    purchases_count = Repo.one(query)
    total_neighbors = length(neighbors)

    if total_neighbors > 0 do
      purchases_count / total_neighbors * 100
    else
      0
    end
  end
end
