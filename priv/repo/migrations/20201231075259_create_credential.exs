defmodule SuperIssuer.Repo.Migrations.CreateCredential do
  use Ecto.Migration

  def change do
    create table :credential do
      add :credential, :map
      add :user_id, :integer
      timestamps()
    end
  end
end
