defmodule SuperIssuer.Repo.Migrations.UpdateEventWithEventDecoded do
  use Ecto.Migration

  def change do
    alter table :event do
      add :event_decoded, :map
    end
  end
end
