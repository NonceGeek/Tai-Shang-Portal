defmodule SuperIssuer.Repo.Migrations.UpdateAccountWithType do
  use Ecto.Migration

  def change do
    alter table :account do
      add :type, :string
    end
  end
end
