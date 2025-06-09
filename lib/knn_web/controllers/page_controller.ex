defmodule KnnWeb.PageController do
  use KnnWeb, :controller

  alias Knn.Customers
  alias Knn.Predictor

  defp form_options do
    %{
      category_options: Customers.list_unique_values(:category),
      gender_options: Customers.list_unique_values(:gender),
      city_options: Customers.list_unique_values(:city),
      payment_method_options: Customers.list_unique_values(:payment_method)
    }
  end

  def index(conn, _params) do
    assigns =
      %{
        form_data: %{},
        result: nil
      }
      |> Map.merge(form_options())

    render(conn, :index, assigns)
  end

  def predict(conn, params) do
    # Lista blanca de claves que tu predictor espera
    expected_keys =
      ~w(category gender age city payment_method discount_applied rating purchase_date purchase_amount)a

    atom_params =
      for {k, v} <- params, k in Enum.map(expected_keys, &Atom.to_string/1), into: %{} do
        {String.to_atom(k), v}
      end

    result = Predictor.predict_repeat_customer(atom_params, String.to_integer(params["k"]))

    assigns =
      %{
        form_data: params,
        result: result
      }
      |> Map.merge(form_options())

    render(conn, :index, assigns)
  end

  def city_suggestions(conn, %{"q" => query}) do
    suggestions =
      Knn.Customers.city_suggestions(query)

    json(conn, suggestions)
  end
end
