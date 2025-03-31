defmodule Knn.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :customer_id, :uuid
      add :age, :integer
      add :gender, :string
      add :city, :string
      add :category, :string
      add :product_name, :string
      add :purchase_date, :date
      add :purchase_amount, :float
      add :payment_method, :string
      add :discount_applied, :string
      add :rating, :integer
      add :repeat_customer, :string

      timestamps(type: :utc_datetime)
    end
  end
end
