defmodule SuperIssuer.Tx do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.Repo
  alias SuperIssuer.{Block, Chain, Tx, Event, Contract}

  schema "tx" do
    field :tx_hash, :string
    field :from, :string
    field :to, :string
    field :input, :string
    field :value, :integer
    field :input_decoded, :map
    belongs_to :block, Block
    belongs_to :contract, Contract
    has_many :event, Event
    timestamps()
  end

  def preload(ele) do
    Repo.preload(ele, [:block, :contract, :event])
  end

  def get_by_hash(ele) do
    Repo.get_by(Tx, tx_hash: ele)
  end

  def create_tx(attrs \\ %{}) do
    %Tx{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def changeset(%Tx{} = ele, attrs) do
    ele
    |> cast(attrs, [:contract, :from, :to, :input, :value, :input_decoded, :tx_hash, :block_id, :contract_id])
  end
end
