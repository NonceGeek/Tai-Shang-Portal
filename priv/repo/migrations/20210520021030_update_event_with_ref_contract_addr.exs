defmodule SuperIssuer.Repo.Migrations.UpdateEventWithRefContractAddr do
  use Ecto.Migration

  def change do
    alter table :event do
      add :ref_contract_addr, :string
    end
  end
end
