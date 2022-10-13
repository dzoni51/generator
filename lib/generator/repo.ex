defmodule Generator.Repo do
  use Ecto.Repo,
    otp_app: :generator,
    adapter: Ecto.Adapters.Postgres
end
