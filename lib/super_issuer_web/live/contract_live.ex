defmodule SuperIssuerWeb.ContractLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.ContractView
  alias SuperIssuer.{User, Contract}

  def render(assigns) do
    ContractView.render("contract.html", assigns)
  end

  def mount(_params, %{
    "current_user_id" => id
  }, socket) do
    user = User.get_by_user_id(id)
    contracts =
      Contract.get_all()
      |> Enum.map(fn contract ->
        contract
        |> Map.put(:init_params, Poison.encode!(contract.init_params))
      end)
    {:ok,
      socket
      |> do_mount(user)
      |> assign(contracts: contracts)
    }
  end

  def mount(_params, _, socket) do
    {:ok,
    socket
    |> redirect(to: "/")
  }
  end

  def do_mount(socket, %{group: 1}) do
    changeset = Contract.changeset(%Contract{})
    socket
    |> assign(changeset: changeset)
  end

  def do_mount(socket, _others) do
    socket
    |> redirect(to: "/")
  end

  def handle_event("save", %{"contract" => contract}, socket) do

    contract =
      contract
      |> StructTranslater.to_atom_struct()
      |> Contract.handle()

    case Contract.create(contract) do
      {:ok, contract} ->
        {:noreply,
        socket
        |> put_flash("info", "contract created")
      }
      {:error, reason} ->
        {:noreply,
        socket
        |> put_flash("error", inspect(reason))
      }
    end
  end
  def handle_event(sth, payload, socket) do
    {:noreply, socket}
  end

end
