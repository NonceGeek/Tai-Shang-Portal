defmodule SuperIssuer.Repo.Migrations.UpdateContractTemplate do
  use Ecto.Migration

  def change do
    alter table :contract_template do
      add :source_code, :text
    end
  end
end
