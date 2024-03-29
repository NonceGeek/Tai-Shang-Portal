defmodule SuperIssuer.Block do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias SuperIssuer.Repo
  alias SuperIssuer.{Block, Chain, Tx}

  schema "block" do
    field :block_height, :integer
    field :block_hash, :string
    field :timestamp, :integer
    belongs_to :chain, Chain
    has_many :tx, Tx
    timestamps()
  end

  def get_newest() do
    Repo.one(
      from b in Block,
        order_by: [desc: b.id],
        limit: 1
    )
  end
  def preload(ele) do
    Repo.preload(ele, :chain)
  end

  def get_by_height(ele) do
    Repo.get_by(Block, block_height: ele)
  end

  def get_by_hash(ele) do
    Repo.get_by(Block, block_hash: ele)
  end

  def create_block(attrs \\ %{}) do
    %Block{}
    |> Block.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def changeset(%Block{} = ele, attrs) do
    ele
    |> cast(attrs, [:block_height, :block_hash, :chain_id, :timestamp])
  end
end
