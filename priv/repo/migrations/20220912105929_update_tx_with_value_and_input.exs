defmodule SuperIssuer.Repo.Migrations.UpdateTxWithValueAndInput do
  use Ecto.Migration

  def change do
    alter table :tx do
      add :input, :text
      add :value, :integer
    end
  end
end
