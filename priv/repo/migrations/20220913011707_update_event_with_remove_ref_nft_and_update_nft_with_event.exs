defmodule SuperIssuer.Repo.Migrations.UpdateEventWithRemoveRefNftAndUpdateNftWithEvent do
  use Ecto.Migration

  def change do
    alter table :event do
      remove :ref_nft
      remove :ref_contract_addr
      add :nft_id, :integer
    end
  end
end
