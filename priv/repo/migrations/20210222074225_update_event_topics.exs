defmodule SuperIssuer.Repo.Migrations.UpdateEventTopics do
  use Ecto.Migration

  def change do
    alter table :event do
      add :topics, {:array, :string}
      remove :data
    end
  end
end
