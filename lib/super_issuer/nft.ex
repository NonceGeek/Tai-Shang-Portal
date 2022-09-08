defmodule SuperIssuer.Nft do
    alias SuperIssuer.Nft, as: Ele
    alias SuperIssuer.Repo
    alias SuperIssuer.Contract
    use Ecto.Schema
    import Ecto.{Changeset, Query}
    require Logger

    @int_limit 2147483647

    schema "nft" do
      field :token_id, :integer
      field :uri, :map
      field :owner, :string
      belongs_to :contract, Contract

      timestamps()
    end

    def check_owner(owner) do
      Ele
      |> where([e], e.owner == ^String.downcase(owner))
      |> Repo.all()
    end
    def get_all() do
      Repo.all(Ele)
    end

    def get_all(owner) do
      Ele
      |> where([e], e.owner == ^String.downcase(owner))
      |> Repo.all()
      |> Enum.map(&(preload(&1)))
    end

    def count(contract_id) do
      Ele
      |> where([n], n.contract_id == ^contract_id)
      |> select(count("*"))
      |> Repo.one()
    end

    def get_by_token_id_and_contract_id(token_id, contract_id) do
      if token_id <= @int_limit do
        try do
          Ele
          |> where([n], n.token_id == ^token_id and n.contract_id == ^contract_id)
          |> Repo.all()
          |> Enum.fetch!(0)
        rescue
          _ ->
            nil
        end
      else
        nil
      end
    end

    def preload(ele) do
      Repo.preload(ele, [nft_contract: :chain, badge_id: :badge])
    end

    def get_by_id(id) do
      Ele
      |> Repo.get_by(id: id)
      |> preload()
    end

    def get_by_token_id(token_id) do
      if token_id <= @int_limit do
        Ele
        |> Repo.get_by(token_id: token_id)
        |> preload()
      else
        nil
      end
    end

    def create(%{token_id: token_id} = attrs) do
      if token_id <= @int_limit do
        %Ele{}
        |> Ele.changeset(attrs)
        |> Repo.insert()
      else
        {:ok, "token_id is too large"}
      end
    end

    def update(%Ele{} = ele, %{token_id: token_id} = attrs) do
      if token_id <= @int_limit do
        ele
        |> changeset(attrs)
        |> Repo.update()
      else
        {:ok, "token_id is too large"}
      end
    end

    def update(%Ele{} = ele, attrs) do
      ele
      |> changeset(attrs)
      |> Repo.update()
    end

    def changeset(%Ele{} = ele) do
      Ele.changeset(ele, %{})
    end

    @doc false
    def changeset(%Ele{} = ele, attrs) do
      ele
      |> cast(attrs, [:token_id, :uri, :contract_id, :owner])
      |> validate_not_nil([:contract_id])
      |> update_change(:owner, &String.downcase/1)
    end

    def validate_not_nil(changeset, fields) do
      Enum.reduce(fields, changeset, fn field, changeset ->
        if get_field(changeset, field) == nil do
          add_error(changeset, field, "nil")
        else
          changeset
        end
      end)
    end
  end
