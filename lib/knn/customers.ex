defmodule Knn.Customers do
  import Ecto.Query, warn: false
  alias Knn.Repo
  alias Knn.Customer

  def will_return?(params, k \\ 5) do
    # Filtrar solo clientes con historial de compras (para aprender del pasado)
    customers =
      from(c in Customer, where: c.repeat_customer == "Yes")
      |> Repo.all()

    if length(customers) == 0 do
      {:error, "No hay datos suficientes para predecir"}
    else
      customers
      |> Enum.map(fn customer ->
        {customer, distance(params, customer)}
      end)
      |> Enum.sort_by(fn {_customer, dist} -> dist end)
      |> Enum.take(k)
      |> decision()
    end
  end

  defp distance(params, customer) do
    age_diff = params.age - customer.age
    gender_diff = if params.gender == customer.gender, do: 0, else: 10
    city_diff = if params.city == customer.city, do: 0, else: 5
    payment_diff = if params.payment_method == customer.payment_method, do: 0, else: 3
    discount_diff = if params.discount_applied == customer.discount_applied, do: 0, else: 2
    rating_diff = params.rating - customer.rating

    :math.sqrt(
      age_diff * age_diff + gender_diff + city_diff +
      payment_diff + discount_diff + rating_diff * rating_diff
    )
  end

  defp decision(neighbors) do
    repeat_count = Enum.count(neighbors, fn {customer, _} -> customer.repeat_customer == "Yes" end)
    if repeat_count >= div(length(neighbors), 2) do
      {:ok, "Probable que vuelva"}
    else
      {:ok, "Probable que NO vuelva"}
    end
  end
end
