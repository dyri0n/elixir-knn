defmodule Knn.Predictor do
  alias Knn.{Repo, Customer}
  import Ecto.Query

  def predict_repeat_customer(input_data, k) do
    training_data = get_training_data()
    encoded_input = encode_row(input_data)

    neighbors =
      training_data
      |> Enum.map(fn row ->
        {row, euclidean_distance(encoded_input, Map.drop(row, [:id, :repeat_customer]))}
      end)
      |> Enum.sort_by(fn {_row, dist} -> dist end)
      |> Enum.take(k)

    IO.puts("\nNearest Neighbors:")

    Enum.each(neighbors, fn {row, dist} ->
      IO.puts("- #{inspect(row)} (distance: #{Float.round(dist, 2)})")
    end)

    yes_count =
      Enum.count(neighbors, fn {row, _} -> row.repeat_customer == 1 end)

    if yes_count > div(k, 2), do: "Yes", else: "No"
  end

  defp get_training_data do
    from(c in Customer,
      select: %{
        id: c.id,
        gender: c.gender,
        age: c.age,
        city: c.city,
        payment_method: c.payment_method,
        discount_applied: c.discount_applied,
        rating: c.rating,
        repeat_customer: fragment("CASE WHEN ? = 'Yes' THEN 1 ELSE 0 END", c.repeat_customer)
      }
    )
    |> Repo.all()
    |> Enum.filter(fn row ->
      row.age != nil and row.gender != nil and row.city != nil and row.payment_method != nil and
        row.discount_applied != nil and row.rating != nil
    end)
    |> Enum.map(&encode_row/1)
  end

  defp encode_row(row) when is_map(row) do
    base = %{
      category: row[:category] || row["category"],
      gender: row[:gender] || row["gender"],
      age: parse_int(row[:age] || row["age"]),
      city: row[:city] || row["city"],
      payment_method: row[:payment_method] || row["payment_method"],
      discount_applied: parse_bool(row[:discount_applied] || row["discount_applied"]),
      rating: parse_int(row[:rating] || row["rating"]),
      purchase_date: row[:purchase_date] || row["purchase_date"],
      purchase_amount: parse_float(row[:purchase_amount] || row["purchase_amount"])
    }

    # Solo agrega repeat_customer si existe en el input
    if Map.has_key?(row, :repeat_customer) or Map.has_key?(row, "repeat_customer") do
      Map.put(base, :repeat_customer, row[:repeat_customer] || row["repeat_customer"])
    else
      base
    end
  end

  defp hash(value), do: :erlang.phash2(value, 1000)
  defp parse_int(nil), do: nil
  defp parse_int(val) when is_binary(val), do: String.to_integer(val)
  defp parse_int(val), do: val

  defp parse_float(nil), do: nil
  defp parse_float(val) when is_float(val), do: val
  defp parse_float(val) when is_integer(val), do: val * 1.0

  defp parse_float(val) when is_binary(val) do
    case Float.parse(val) do
      {num, _} ->
        num

      :error ->
        case Integer.parse(val) do
          {int, _} -> int * 1.0
          :error -> nil
        end
    end
  end

  defp parse_float(val), do: val

  defp parse_bool("true"), do: true
  defp parse_bool("false"), do: false
  defp parse_bool(val), do: val

  defp euclidean_distance(a, b) do
    Enum.zip(Map.values(a), Map.values(b))
    |> Enum.map(fn
      {x, y} when is_number(x) and is_number(y) ->
        (x - y) * (x - y)

      {x, y} when is_binary(x) and is_binary(y) ->
        hx = :erlang.phash2(x, 1000)
        hy = :erlang.phash2(y, 1000)
        (hx - hy) * (hx - hy)

      {x, y} when is_boolean(x) and is_boolean(y) ->
        if x == y, do: 0, else: 1

      _ ->
        0
    end)
    |> Enum.sum()
    |> :math.sqrt()
  end
end
