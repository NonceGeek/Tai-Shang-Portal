defmodule SuperIssuer.Repo.Migrations.UpdateContractWithAbiMap do
  use Ecto.Migration

  def change do
    alter table :contract do
      add :abi, {:array, :map}
    end
  end
end
