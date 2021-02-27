defmodule SuperIssuer.Repo.Migrations.UpdateChain do
  use Ecto.Migration

  def change do
    alter table :chain do
      add :height_now, :integer
    end
  end
end
