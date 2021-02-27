defmodule SuperIssuer.Repo.Migrations.UpdateEvidence do
  use Ecto.Migration

  def change do
    alter table :evidence do
      remove :describe
      add :description, :string
    end
  end
end
