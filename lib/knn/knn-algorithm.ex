defmodule Knn.Algorithm do
  alias Knn.Probability
  alias Knn.Predictions
  alias Knn.{Repo, Customer}
  alias Knn.Util

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
    k1 = IO.gets("Number of neighbors (k1): ") |> String.trim() |> String.to_integer()
    k2 = IO.gets("Number of neighbors (k2): ") |> String.trim() |> String.to_integer()
    process_prediction(input_data, k1, k2)
  end

  def get_console_input do
    IO.puts("Enter the following parameters:")

    category_default = "Clothing"
    gender_default = "Male"
    age_default = 30
    city_default = "New York"
    payment_method_default = "Credit Card"
    discount_applied_default = true
    rating_default = 5
    purchase_date_default = ~D[2025-01-01]
    purchase_amount_default = 50.0

    category = Util.get_input_with_default("Category: ", category_default)
    gender = Util.get_input_with_default("Gender: ", gender_default)
    age = Util.get_input_integer_with_default("Age: ", age_default)
    city = Util.get_input_with_default("City: ", city_default)
    payment_method = Util.get_input_with_default("Payment Method: ", payment_method_default)
    discount_applied = Util.get_input_boolean_with_default("Discount Applied (true/false): ", discount_applied_default)
    rating = Util.get_input_integer_with_default("Rating: ", rating_default)
    purchase_date = Util.get_input_date_with_default("Purchase Date (YYYY-MM-DD): ", purchase_date_default)
    purchase_amount = Util.get_input_float_with_default("Purchase Amount: ", purchase_amount_default)

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

  defp process_prediction(input_data, k1, k2) do
    predict_if_someone_will_return(input_data, k1, k2)
    # change if another function needs testing
  end

  defp predict_if_someone_will_return(input_data, k1, k2) do
    similar_customers = Probability.find_similar_non_returning(input_data, k1)
    repurchase_rate = Probability.find_repurchase_rate(similar_customers, k2)
  end
end
