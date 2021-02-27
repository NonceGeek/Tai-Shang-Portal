defmodule SuperIssuer.Repo.Migrations.AddContractAbiAndChain do
  use Ecto.Migration

  def change do
    alter table :contract do
      add :abi, :string
    end

    create table :chain do
      add :name, :string
      add :min_height, :integer
      add :is_enabled, :boolean
      add :adapter, :string
      add :config, :map
      timestamps()
    end

    create table :block do
      add :chain_id, :integer
      add :block_height, :integer
      add :block_hash, :string
      timestamps()
    end

    create table :tx do
      add :block_id, :integer
      add :tx_hash, :string
      add :from, :string
      add :to, :string
      timestamps()
    end

    create table :event do
      add :tx_id, :integer
      add :topics, :string
      add :data, :string
    end

    alter table :contract do
      add :chain_id, :integer
    end

    alter table :weidentity do
      add :chain_id, :integer
    end
  end
end
