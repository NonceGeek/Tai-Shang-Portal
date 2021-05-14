defmodule SuperIssuer.Repo.Migrations.UpdateWeidWithPrivkey do
  use Ecto.Migration

  def change do
    alter table :weidentity do
      add :encrypted_privkey, :binary
      add :type, :string
    end
  end
end
