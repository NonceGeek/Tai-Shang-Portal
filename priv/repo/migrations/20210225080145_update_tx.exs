defmodule SuperIssuer.Repo.Migrations.UpdateTx do
  use Ecto.Migration

  def change do
    alter table :tx do
      add :contract_id, :integer
    end
  end
end
