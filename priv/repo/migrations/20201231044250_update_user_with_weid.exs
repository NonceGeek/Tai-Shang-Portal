defmodule SuperIssuer.Repo.Migrations.UpdateUserWithWeid do
  use Ecto.Migration

  def change do
    alter table :user do
      add :weid, :string
    end
  end
end
