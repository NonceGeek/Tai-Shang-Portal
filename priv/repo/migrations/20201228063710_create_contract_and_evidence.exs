defmodule SuperIssuer.Repo.Migrations.CreateContractAndEvidence do
  use Ecto.Migration

  def change do
    create table :contract do
      add :addr, :string
      add :type, :string
      add :describe, :string
      add :creater, :string
      add :init_params, :map

      timestamps()
    end

    create table :evidence do
      add :key, :string
      add :value, :string
      add :describe, :string
      add :tx_id, :string

      add :owners, {:array, :string}
      add :signers, {:array, :string}
      add :contract_id, :integer

      timestamps()

    end
  end
end
