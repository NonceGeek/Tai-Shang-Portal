defmodule SuperIssuer.Repo.Migrations.CreateServiceCoupon do
  use Ecto.Migration

  def change do
    create table :service_coupon do
      add :service_name, :string
      add :coupon, :string, default: false
      add :is_used, :boolean

      timestamps()
    end

    create unique_index(:service_coupon, [:coupon])
  end
end
