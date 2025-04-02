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

  def find_repurchase_rate(similar_customers, k) do
    Enum.map(similar_customers, fn customer ->
      start_date = customer.purchase_date
      end_date = Date.add(start_date, 30)

      query =
        from(c in Customer,
          where:
            c.purchase_date >= ^start_date and
              c.purchase_date <= ^end_date and
              c.repeat_customer == "Yes",
          select: c
        )

      repurchased_customers = Repo.all(query)
      repurchase_rate = length(repurchased_customers) / k

      {customer, repurchase_rate}
    end)
  end
end
