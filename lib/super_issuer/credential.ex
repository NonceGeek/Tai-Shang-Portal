defmodule SuperIssuer.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.{Credential, User}
  alias SuperIssuer.Repo

  schema "credential" do
    field :credential, :map
    belongs_to :user, User
    timestamps()
  end

  def preload(cre) do
    Repo.preload(cre, :user)
  end
  def get_all() do
    Repo.all(Credential)
  end

  def create(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(%Credential{} = cre) do
    Credential.changeset(cre, %{})
  end
  @doc false
  def changeset(%Credential{} = cre, attrs) do
    cre
    |> cast(attrs,
      [:credential, :user_id]
    )
  end

end
