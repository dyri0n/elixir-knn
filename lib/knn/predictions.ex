defmodule Knn.Predictions do
  import Ecto.Query
  alias Knn.{Repo, Customer}

  def get_training_data do
    query =
      from c in Customer,
        where: c.repeat_customer == "No",
        select: {
          c.gender,
          c.age,
          c.city,
          c.payment_method,
          c.discount_applied,
          c.rating,
          # Guardamos el ID para buscar después si compró
          c.id
        }

    Repo.all(query)
    |> Enum.map(fn {gender, age, city, payment_method, discount_applied, rating, id} ->
      %{
        # Necesario para buscar después
        id: id,
        gender: hash_value(gender),
        age: age,
        city: hash_value(city),
        payment_method: hash_value(payment_method),
        discount_applied: if(discount_applied == "Yes", do: 1, else: 0),
        rating: rating
      }
    end)
  end

  # El One-Hot Encoding (OHE) es una técnica para convertir datos categóricos
  # en una representación numérica binaria. En lugar de asignar un único número
  # a cada categoría (como 0, 1, 2), creamos varias columnas, donde cada una
  # representa una categoría y tiene un 1 en la posición correspondiente
  # y 0 en las demás.
  def encode_row(%{
        gender: gender,
        age: age,
        city: city,
        payment_method: payment_method,
        discount_applied: discount_applied,
        rating: rating
      }) do
    %{
      gender: hash_value(gender),
      age: age,
      city: hash_value(city),
      payment_method: hash_value(payment_method),
      discount_applied: if(discount_applied == "Yes", do: 1, else: 0),
      rating: rating
    }
  end

  def encode_row(%{
        gender: gender,
        age: age,
        city: city,
        payment_method: payment_method,
        discount_applied: discount_applied,
        rating: rating,
        repeat_customer: repeat_customer
      }) do
    %{
      gender: hash_value(gender),
      age: age,
      city: hash_value(city),
      payment_method: hash_value(payment_method),
      discount_applied: if(discount_applied == "Yes", do: 1, else: 0),
      rating: rating,
      repeat_customer: if(repeat_customer == "Yes", do: 1, else: 0)
    }
  end

  def encode_row(%{
        category: category,
        gender: gender,
        age: age,
        city: city,
        payment_method: payment_method,
        discount_applied: discount_applied,
        rating: rating,
        purchase_date: purchase_date,
        purchase_amount: purchase_amount
      }) do
    %{
      category: hash_value(category),
      gender: hash_value(gender),
      age: age,
      city: hash_value(city),
      payment_method: hash_value(payment_method),
      discount_applied: if(discount_applied == "Yes", do: 1, else: 0),
      rating: rating,
      # Convertimos la fecha a string ISO8601
      purchase_date: Date.to_iso8601(purchase_date),
      purchase_amount: purchase_amount
    }
  end

  defp hash_value(value) do
    # 1000 es el número de "buckets" o categorías posibles
    :erlang.phash2(value, 1000)
  end
end
