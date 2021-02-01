defmodule SuperIssuer.Repo.Migrations.CreateSchool do
  use Ecto.Migration

  def change do
    create table :school do
      add :school_id, :string
      add :image_path, :string
      add :node_id, :string
      add :url, :string
      add :school_name, :string
      add :representative,{:array, :map}
      timestamps()
    end
  end
end
