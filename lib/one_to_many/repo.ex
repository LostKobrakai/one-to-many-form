defmodule OneToMany.Repo do
  use Ecto.Repo,
    otp_app: :one_to_many,
    adapter: Ecto.Adapters.Postgres
end
