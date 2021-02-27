defmodule SuperIssuer.Repo.Migrations.AddAppWeidPermission do
  use Ecto.Migration

  def change do
    alter table :app do
      add :weid_permission, :integer
    end
  end
end
