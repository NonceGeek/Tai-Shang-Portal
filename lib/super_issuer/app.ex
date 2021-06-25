defmodule SuperIssuer.App do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias SuperIssuer.{User, App, Contract}
  alias SuperIssuer.Repo


  schema "app" do
    field :name, :string
    field :description, :string
    field :encrypted_secret_key, :binary
    field :contract_id_list, {:array, :integer}
    field :weid_permission, :integer
    field :url, :string
    belongs_to :user, User
    timestamps()
  end

  def count() do
    App
    |> select(count("*"))
    |> Repo.one()
  end
  def get_all() do
    Repo.all(App)
  end
  def get_by_id(nil), do: nil
  def get_by_id(ele) do
    App
    |> Repo.get_by(id: ele)
    |> get_app_with_contract()
  end

  def handle_result(nil), do: {:error, nil}
  def handle_result(app), do: {:ok, app}
  def get_by_name(nil), do: nil

  def get_by_name(ele) do
    App
    |> Repo.get_by(name: ele)
    |> get_app_with_contract()
  end

  def get_app_with_contract(nil), do: nil
  def get_app_with_contract(app) do
    contracts = get_contracts(app)
    Map.put(app, :contracts, contracts)
  end

  def get_contracts(ele) when is_nil(ele) do
    nil
  end

  def get_contracts(%{contract_id_list: contract_id_list}) do
    Enum.map(contract_id_list, fn c_id ->
      Contract.get_by_id(c_id)
    end)
  end

  def create(attrs \\ %{}) do
    %App{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def change(%App{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%App{} = ele) do
    changeset(ele, %{})
  end

  @doc false
  def changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:name, :encrypted_secret_key, :description, :contract_id_list, :url, :weid_permission, :user_id])
    |> unique_constraint(:name)
    |> validate_required([:name, :encrypted_secret_key])
    |> update_change(:encrypted_secret_key, &Crypto.encrypt_key/1)
  end
end
