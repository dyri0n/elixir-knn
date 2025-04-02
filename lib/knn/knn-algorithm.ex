defmodule Knn.Algorithm do
  alias Knn.Probability
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

  def find_k_nearest_neighbors(target, dataset, k) do
    dataset
    |> Enum.map(fn customer ->
      {customer,
       euclidean_distance(
         Predictions.encode_row(target),
         Predictions.encode_row(customer)
       )}
    end)
    |> Enum.sort_by(fn {_customer, distance} -> distance end)
    |> Enum.take(k)
    |> Enum.map(fn {customer, _distance} -> customer end)
  end

  defp euclidean_distance(a, b) do
    a_values = Map.values(a)
    b_values = Map.values(b)

    a_values
    |> Enum.zip(b_values)
    |> Enum.map(fn {x, y} -> (x - y) ** 2 end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  def console_predict do
    input_data = get_console_input()
    k = IO.gets("Number of neighbors (k): ") |> String.trim() |> String.to_integer()
    process_prediction(input_data, k)
  end

  def get_console_input do
    IO.puts("Enter the following parameters:")

    category = IO.gets("Category: ") |> String.trim()
    gender = IO.gets("Gender: ") |> String.trim()
    age = IO.gets("Age: ") |> String.trim() |> String.to_integer()
    city = IO.gets("City: ") |> String.trim()
    payment_method = IO.gets("Payment Method: ") |> String.trim()

    discount_applied =
      IO.gets("Discount Applied (true/false): ")
      |> String.trim()
      |> String.downcase()
      |> to_boolean()

    rating = IO.gets("Rating: ") |> String.trim() |> String.to_integer()

    purchase_date =
      IO.gets("Purchase Date (YYYY-MM-DD): ")
      |> String.trim()
      |> Date.from_iso8601!()

    purchase_amount =
      IO.gets("Purchase Amount: ")
      |> String.trim()
      |> Float.parse()
      |> elem(0)

    %{
      category: category,
      gender: gender,
      age: age,
      city: city,
      payment_method: payment_method,
      discount_applied: discount_applied,
      rating: rating,
      purchase_date: purchase_date,
      purchase_amount: purchase_amount
    }
  end

  defp process_prediction(input_data, k) do
    Probability.find_similar_non_returning(input_data, k)
  end

  defp to_boolean("true"), do: true
  defp to_boolean("false"), do: false
  defp to_boolean(_), do: raise("Invalid boolean value")
end
