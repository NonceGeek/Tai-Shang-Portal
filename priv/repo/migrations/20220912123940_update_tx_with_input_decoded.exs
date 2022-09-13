defmodule SuperIssuer.Repo.Migrations.UpdateTxWithInputDecoded do
  use Ecto.Migration

  def change do
    alter table :tx do
      add :input_decoded, :map
    end
  end
end
