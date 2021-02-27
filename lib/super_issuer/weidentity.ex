defmodule SuperIssuer.WeIdentity do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.{Repo, User, WeIdentity, Chain}

  schema "weidentity" do
    field :weid, :string
    field :description, :string
    belongs_to :user, User
    belongs_to :chain, Chain
    timestamps()
  end

  def get_by_weid(ele) when is_nil(ele), do: nil
  def get_by_weid(ele) do
    Repo.get_by(WeIdentity, weid: ele)
  end

  def create_weidentity(attrs \\ %{}) do
    %WeIdentity{}
    |> WeIdentity.changeset(attrs)
    |> Repo.insert()
  end

  def change_weidentity(%WeIdentity{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%WeIdentity{} = ele) do
    WeIdentity.changeset(ele, %{})
  end

  @doc false
  def changeset(%WeIdentity{} = ele, attrs) do
    ele
    |> cast(attrs, [:weid, :description, :user_id])
  end
end
