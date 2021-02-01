defmodule SuperIssuer.Repo do
  use Ecto.Repo,
    otp_app: :super_issuer,
    adapter: Ecto.Adapters.Postgres
end
