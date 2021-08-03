defmodule SuperIssuer.ServiceCoupon do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.ServiceCoupon, as: Ele
  alias SuperIssuer.Repo

  schema "service_coupon" do
    field :service_name, :string
    field :coupon, :string

    field :is_used, :boolean, default: false

    timestamps()
  end

  @doc """
    generate a new coupon.
  """
  def generate(service_name) do
    coupon = RandGen.gen_hex(16)
    create(
      %{
        service_name: service_name,
        coupon: coupon
    })
  end

  def get_by_id(id) do
    Repo.get_by(Ele, id: id)
  end

  def get_by_service_id(service_name) do
    Repo.all(Ele, service_name: service_name)
  end

  def get_by_coupon(coupon) do
    Repo.get_by(Ele, coupon: coupon)
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
    Ele.changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:service_name, :coupon, :is_used])
    |> unique_constraint(:coupon)
  end
end
