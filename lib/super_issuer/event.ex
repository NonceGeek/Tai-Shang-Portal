defmodule SuperIssuer.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.Repo
  alias SuperIssuer.{Tx, Event}

  schema "event" do
    field :topics, {:array, :string}
    field :data, :string
    field :address, :string
    field :log_index, :integer
    belongs_to :tx, Tx
    timestamps()
  end

  def get_all() do
    Repo.all(Event)
  end
  def get_by_id(ele) do
    Repo.get_by(Event, id: ele)
  end
  def get_by_addr(ele) do
    Repo.get_by(Event, address: ele)
  end
  def preload(ele) do
    Repo.preload(ele, :tx)
  end

  def create_event(attrs \\ %{}) do
    %Event{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def changeset(%Event{} = ele, attrs) do
    ele
    |> cast(attrs, [:topics, :data, :tx_id, :address, :log_index])
  end
end
