defmodule SuperIssuer.Chain do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.Repo
  alias SuperIssuer.{WeIdentity, Contract, Chain}
  schema "chain" do
    field :name, :string
    field :min_height, :integer
    field :is_enabled, :boolean
    field :adapter, :string
    field :config, :map
    field :height_now, :integer
    has_many :weidentity, WeIdentity
    has_many :contract, Contract
    timestamps()
  end

  def get_height_now(%{height_now: height}) do
    do_get_height_now(height)
  end
  def do_get_height_now(nil), do: 0
  def do_get_height_now(height), do: height

  def get_default_chain() do
    get_by_id(1)
  end
  def preload(ele) do
    ele
    |> Repo.preload([:contract, :weidentity])
  end

  def get_all() do
    Repo.all(Chain)
  end

  def get_by_name(ele) do
    Repo.get_by(Chain, name: ele)
  end

  def get_by_id(ele) do
    Repo.get_by(Chain, id: ele)
  end

  def create(attrs \\ %{}) do
    %Chain{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def change(%Chain{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Chain{} = ele) do
    changeset(ele, %{})
  end

  @doc false
  def changeset(%Chain{} = ele, attrs) do
    ele
    |> cast(attrs, [:name, :min_height, :is_enabled, :adapter, :config, :height_now])
    |> unique_constraint(:name)
  end
end
