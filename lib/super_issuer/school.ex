defmodule SuperIssuer.School do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.Repo
  alias SuperIssuer.School,as: Ele

  schema "school" do
    field :school_id, :string
    field :image_path, :string
    field :node_id, :string
    field :url, :string
    field :school_name, :string
    field :representative,{:array, :map}
    timestamps()
  end

  def get_all() do
    Repo.all(Ele)
  end
  def get_by_school_id(ele) do
    Repo.get_by(Ele, school_id: ele)
  end

    def get_by_school_name(ele) do
    Repo.get_by(Ele, school_name: ele)
  end


  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(%Ele{} = ele) do
    Ele.changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(
      attrs,
      [:school_id, :image_path, :node_id, :url, :school_name, :representative]
      )
  end
end
