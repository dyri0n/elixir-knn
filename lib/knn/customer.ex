defmodule Knn.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :category, :string
    field :customer_id, Ecto.UUID
    field :age, :integer
    field :gender, :string
    field :city, :string
    field :product_name, :string
    field :purchase_date, :date
    field :purchase_amount, :float
    field :payment_method, :string
    field :discount_applied, :string
    field :rating, :integer
    field :repeat_customer, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:customer_id, :age, :gender, :city, :category, :product_name, :purchase_date, :purchase_amount, :payment_method, :discount_applied, :rating, :repeat_customer])
    |> validate_required([:customer_id, :age, :gender, :city, :category, :product_name, :purchase_date, :purchase_amount, :payment_method, :discount_applied, :rating, :repeat_customer])
  end
end
