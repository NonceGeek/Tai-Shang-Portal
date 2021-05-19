defmodule SuperIssuer.Repo.Migrations.UpdateWeidentityWithAppId do
  use Ecto.Migration

  def change do
    alter table :weidentity do
      add :app_id, :integer
    end
  end
end
