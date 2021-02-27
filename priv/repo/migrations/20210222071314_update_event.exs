defmodule SuperIssuer.Repo.Migrations.UpdateEvent do
  use Ecto.Migration

  def change do
    alter table :event do
      add :address, :string
      add :log_index, :integer
      remove :topics
      add :topics, {:array, :string}
    end
  end
end
