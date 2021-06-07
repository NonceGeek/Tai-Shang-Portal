defmodule SuperIssuer.Repo.Migrations.UpdateEventWithRefOperator do
  use Ecto.Migration

  def change do
    alter table :event do
      add :ref_operator, :string
      add :ref_weid, :string
    end
  end
end
