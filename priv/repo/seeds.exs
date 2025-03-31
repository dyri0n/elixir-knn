# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Knn.Repo.insert!(%Knn.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Knn.Seed do
  alias Knn.Repo
  alias Knn.Customer

  def run do
    "priv/repo/customers.csv"
    |> File.stream!()
    |> Stream.drop(1)  # Omitir encabezados si existen
    |> Stream.map(&parse_row/1)
    |> Enum.each(&insert_customer/1)
  end

  defp parse_row(row) do
    [customer_id, age, gender, city, category, product_name, purchase_date,
     purchase_amount, payment_method, discount_applied, rating, repeat_customer] =
      String.split(row, ",", trim: true)

    %{
      customer_id: customer_id,
      age: String.to_integer(age),
      gender: gender,
      city: city,
      category: category,
      product_name: product_name,
      purchase_date: Date.from_iso8601!(purchase_date),
      purchase_amount: String.to_float(purchase_amount),
      payment_method: payment_method,
      discount_applied: discount_applied,
      rating: String.to_integer(rating),
      repeat_customer: repeat_customer
    }
  end

  defp insert_customer(customer_data) do
    %Customer{}
    |> Customer.changeset(customer_data)
    |> Repo.insert()
  end
end

Knn.Seed.run()
