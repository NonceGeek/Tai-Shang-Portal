defmodule SuperIssuer.Repo.Migrations.UpdateEventWithWeidAndNft do
  use Ecto.Migration

  def change do
    alter table :event do
      add :ref_nft, :string

    end

    create table :account_event do
      add :account_id, :integer
      add :event_id, :integer
    end
  end
end
