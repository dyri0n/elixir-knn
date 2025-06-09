defmodule Knn.Customers do
  import Ecto.Query
  alias Knn.{Repo, Customer}

  def list_unique_values(field) do
    Customer
    |> select([c], field(c, ^field))
    |> distinct(true)
    |> order_by(^field)
    # Limita en la base de datos
    |> limit(100)
    |> Repo.all()
    |> Enum.reject(&is_nil/1)
    |> tap(fn values -> IO.inspect({field, length(values)}, label: "Unique values count") end)
  end

  def city_suggestions(query) do
    lc_query = String.downcase(query)

    Customer
    |> where([c], like(fragment("lower(?)", c.city), ^"#{lc_query}%"))
    |> select([c], c.city)
    |> distinct(true)
    |> order_by(:city)
    |> limit(10)
    |> Repo.all()
    |> tap(fn values -> IO.inspect({values}, label: "resultados") end)
  end
end
