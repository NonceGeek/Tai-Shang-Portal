defmodule SuperIssuer.Repo.Migrations.UpdateContractsWithErc721TotalNum do
  use Ecto.Migration

  def change do
    alter table :contract do
      add :erc721_total_num, :integer
    end
  end
end
