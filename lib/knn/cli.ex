defmodule Knn.CLI do
  def main do
    IO.puts("\n--- KNN Repeat Customer Predictor ---")
    predict_from_console()
  end

  def predict_from_console do
    input_data = get_console_input()
    k = get_with_default("Number of neighbors (k)", 5, &String.to_integer/1)
    result = Knn.Predictor.predict_repeat_customer(input_data, k)
    IO.puts("\nPrediction: This customer will return? => #{result}")
  end

  def get_console_input do
    IO.puts("\nEnter customer data (or press Enter to use defaults):")

    category_default = "Clothing"
    gender_default = "Male"
    age_default = 30
    city_default = "New York"
    payment_method_default = "Credit Card"
    discount_applied_default = true
    rating_default = 5
    purchase_date_default = ~D[2025-01-01]
    purchase_amount_default = 50.0

    category = get_with_default("Category", category_default)
    gender = get_with_default("Gender", gender_default)
    age = get_with_default("Age", age_default, &String.to_integer/1)
    city = get_with_default("City", city_default)
    payment_method = get_with_default("Payment Method", payment_method_default)
    discount_applied = get_with_default("Discount Applied (true/false)", discount_applied_default, &parse_bool/1)
    rating = get_with_default("Rating", rating_default, &String.to_integer/1)
    purchase_date = get_with_default("Purchase Date (YYYY-MM-DD)", purchase_date_default, &Date.from_iso8601!/1)
    purchase_amount = get_with_default("Purchase Amount", purchase_amount_default, &parse_float/1)

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

  defp get_with_default(prompt, default, parser \\ & &1) do
    input = IO.gets("#{prompt} [default: #{default}]: ") |> String.trim()
    if input == "", do: default, else: parser.(input)
  end

  defp parse_bool("true"), do: true
  defp parse_bool("false"), do: false
  defp parse_bool(_), do: false

  defp parse_float(str) do
    case Float.parse(str) do
      {f, _} -> f
      _ -> 0.0
    end
  end
end
