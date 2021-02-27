defmodule SuperIssuer.Repo.Migrations.UpdateContract do
  use Ecto.Migration

  def change do
    alter table :contract do
      remove :describe
      add :description, :string
    end
  end
end
