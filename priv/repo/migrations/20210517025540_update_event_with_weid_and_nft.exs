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

    create table :weidentity_event do
      add :weidentity_id, :integer
      add :event_id, :integer
    end
  end
end
