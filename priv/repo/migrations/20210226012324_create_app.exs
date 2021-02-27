defmodule SuperIssuer.Repo.Migrations.CreateApp do
  use Ecto.Migration

  def change do
    create table :app do
      add :name, :string
      add :description, :string
      add :encrypted_secret_key, :binary
      add :contract_id_list, {:array, :integer}
      add :user_id, :integer
      timestamps()
    end
  end
end
