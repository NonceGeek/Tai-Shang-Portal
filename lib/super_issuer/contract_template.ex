defmodule SuperIssuer.ContractTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.{Chain, Contract}
  alias SuperIssuer.Repo
  alias SuperIssuer.Ethereum.ABI
  alias SuperIssuer.ContractTemplate, as: Ele

  schema "contract_template" do
    field :name, :string
    field :abi, {:array, :map}
    field :bin, :string
  end

  # +-----------------------------+
  # | Common Action For Contracts |
  # +-----------------------------+

  def get_abi(con_template_name) do
    con_template_name
    |> Ele.get_by_name()
    |> Map.get(:abi)
  end

  def get_bin(con_template_name) do
    con_template_name
    |> Ele.get_by_name()
    |> Map.get(:bin)
  end

  def get_funcs(%{abi: abi}) do
    abi
    |> ABI.get_funcs()
    |> Enum.map(fn func ->
      struct_to_map(:func, func)
    end)
  end

  def get_events(%{abi: abi}) do
    abi
    |> ABI.get_events()
    |> Enum.map(fn event ->
      struct_to_map(:event, event)
    end)
  end

  def struct_to_map(:func, ele) do
    ele = Map.from_struct(ele)
    inputs = Enum.map(ele.inputs, fn arg ->
      Map.from_struct(arg)
    end)
    outputs = Enum.map(ele.outputs, fn arg ->
      Map.from_struct(arg)
    end)
    ele
    |> Map.put(:inputs, inputs)
    |> Map.put(:outputs, outputs)
  end

  def struct_to_map(:event, ele) do
    ele = Map.from_struct(ele)
    args = Enum.map(ele.args, fn arg ->
      Map.from_struct(arg)
    end)
    Map.put(ele, :args, args)
  end

  def get_all() do
    Repo.all(Ele)
  end
  def get_by_name(ele) do
    Repo.get_by(Ele, name: ele)
  end

  def get_by_id(ele) do
    Repo.get_by(Ele, id: ele)
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
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
    |> cast(attrs, [:name, :abi, :bin])
  end
end
