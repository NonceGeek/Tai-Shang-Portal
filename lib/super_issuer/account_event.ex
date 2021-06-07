defmodule SuperIssuer.AccountEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias SuperIssuer.Repo
  alias SuperIssuer.{Account, Event}
  alias SuperIssuer.AccountEvent, as: Ele

  schema "account_event" do
    belongs_to :account , Account
    belongs_to :event, Event
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def change(%Ele{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Ele{} = ele) do
    changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:account_id, :event_id])
  end
end
