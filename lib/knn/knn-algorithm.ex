defmodule Knn.Algorithm do
  alias Knn.Predictions

  def predict(input_data, k \\ 5) do
    training_data = Predictions.get_training_data()

    distances =
      training_data
      |> Enum.map(fn train_row ->
        {train_row, distance(Predictions.encode_row(input_data), train_row)}
      end)
      |> Enum.sort_by(fn {_row, dist} -> dist end)
      |> Enum.take(k)

    classify(distances)
  end

  defp distance(input, train) do
    # Asumimos que ambos mapas tienen las mismas claves
    keys = Map.keys(input)

    squared_diff =
      Enum.map(keys, fn key ->
        a = input[key]
        b = train[key]
        (a - b) ** 2
      end)

    Enum.sum(squared_diff) |> :math.sqrt()
  end

  defp classify(neighbors) do
    counts =
      neighbors
      |> Enum.map(fn {row, _dist} -> row[:repeat_customer] end)
      |> Enum.frequencies()

    Enum.max_by(counts, fn {_class, freq} -> freq end)
    |> elem(0)
  end
end
