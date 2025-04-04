defmodule Knn.Probability do
  alias Knn.Repo
  alias Knn.Customer
  import Ecto.Query

  def find_similar_non_returning(input_customer, k) do
    query =
      from(c in Customer,
        where: c.repeat_customer == "No",
        select:
          map(c, [
            :category,
            :gender,
            :age,
            :city,
            :payment_method,
            :discount_applied,
            :rating,
            :purchase_date,
            :purchase_amount
          ])
      )

    customers = Repo.all(query)

    similar_customers =
      Knn.Algorithm.find_k_nearest_neighbors(input_customer, customers, k)

    similar_customers
  end

  # encontrar a los clientes parecidos a los similares
  # que no han comprado en la ventana de 30 días

  # sumar cuántos de ellos han comprado

  # dividirlo con el promedio mensual
  def find_similar_returning(input_customer, k) do
    start_date = input_customer.purchase_date
    end_date = Date.add(start_date, 30)

    query =
      from(c in Customer,
        where:
          c.purchase_date >= ^start_date and
            c.purchase_date <= ^end_date and
            c.repeat_customer == "Yes",
        select:
          map(c, [
            :category,
            :gender,
            :age,
            :city,
            :payment_method,
            :discount_applied,
            :rating,
            :purchase_date,
            :purchase_amount
          ])
      )

    repurchased_customers = Repo.all(query)

    similar_customers =
      Knn.Algorithm.find_k_nearest_neighbors(input_customer, repurchased_customers, k)

    similar_customers
  end

  def find_repurchase_rate(similar_customers, k \\ 2) do
    total_returning =
      Enum.reduce(similar_customers, 0, fn customer, acc ->
        similar_returning_customers = find_similar_returning(customer, k)
        acc + length(similar_returning_customers)
      end)

    repurchase_rate = total_returning / k
    repurchase_rate
  end
end
