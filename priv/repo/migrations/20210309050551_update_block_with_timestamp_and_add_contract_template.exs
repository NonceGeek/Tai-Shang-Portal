defmodule SuperIssuer.Repo.Migrations.UpdateBlockWithTimestampAndAddContractTemplate do
  use Ecto.Migration

  def change do
    alter table :block do
      add :timestamp, :bigint
    end
    create table :contract_template do
      add :name, :string
      add :abi, {:array, :map}
      add :bin, :text
    end

    alter table :contract do
      remove :abi
      remove :type
      add :contract_template_id, :integer
    end
  end
end
