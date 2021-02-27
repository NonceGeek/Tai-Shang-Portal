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

    alter table :user do
      add :group, :integer
    end
    create table :weidentity do
      add :user_id, :integer
      add :weid, :string
      add :description, :string
      timestamps()
    end
  end
end
