defmodule SuperIssuer.Repo.Migrations.UpdateEventData do
  use Ecto.Migration

  def change do
    alter table :event do
      add :data, :text
    end
  end
end
