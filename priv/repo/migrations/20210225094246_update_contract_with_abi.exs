defmodule SuperIssuer.Repo.Migrations.UpdateContractWithAbi do
  use Ecto.Migration

  def change do
    alter table :contract do
      remove :abi
    end
  end
end
