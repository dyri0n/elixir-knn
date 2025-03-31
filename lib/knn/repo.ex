defmodule Knn.Repo do
  use Ecto.Repo,
    otp_app: :knn,
    adapter: Ecto.Adapters.SQLite3
end
