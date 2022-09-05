defmodule SuperIssuer.Repo.Migrations.UpdateAppWithUrl do
  use Ecto.Migration

  def change do
    alter table :app do
      add :url, :string
      add :chain_tags, {:array, :string}
    end
  end
end
