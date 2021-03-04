defmodule SuperIssuer.Repo.Migrations.UpdateAppWithUrl do
  use Ecto.Migration

  def change do
    alter table :app do
      add :url, :string
    end
  end
end
