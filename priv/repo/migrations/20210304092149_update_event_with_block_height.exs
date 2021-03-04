defmodule SuperIssuer.Repo.Migrations.UpdateEventWithBlockHeight do
  use Ecto.Migration

  def change do
    alter table :event do
      add :block_height, :integer
    end
  end
end
