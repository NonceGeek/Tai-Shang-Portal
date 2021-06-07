defmodule SuperIssuer.Repo.Migrations.UpdateAccount do
  use Ecto.Migration

  def change do
    alter table :account do
      remove :weid_id
      add :weidentity_id, :integer
    end
  end
end
