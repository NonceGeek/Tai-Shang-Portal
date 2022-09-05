defmodule SuperIssuer.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table :account do
      add :addr, :string
      add :ft_balance, :map
      add :nft_balance, :map

      timestamps()
    end
  end
end
