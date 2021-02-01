defmodule SuperIssuer.Contract do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.{Contract, Evidence}
  alias SuperIssuer.Repo

  schema "contract" do
    field :addr, :string
    field :type, :string
    field :describe, :string
    field :creater, :string
    field :init_params, :map
    has_many :evidence, Evidence
    timestamps()
  end

  def get_by_addr(addr) do
    Repo.get_by(Contract, addr: addr)
  end

  def get_by_type(type) do
    Repo.all(Contract, type: type)
  end

  def get_by_describe(item) do
    Repo.get_by(Contract, describe: item)
  end

  def create(attrs \\ %{}) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(%Contract{} = contract) do
    Contract.changeset(contract, %{})
  end

  @doc false
  def changeset(%Contract{} = contract, attrs) do
    contract
    |> cast(attrs, [:addr, :type, :describe, :creater, :init_params])
    |> unique_constraint(:describe)
  end
end
