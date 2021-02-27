defmodule SuperIssuer.Repo.Migrations.UpdateEventTimestamps do
  use Ecto.Migration

  def change do
    alter table :event do
      timestamps()
      remove :topics
    end
  end
end
