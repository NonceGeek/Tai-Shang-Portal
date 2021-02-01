defmodule SuperIssuerWeb.ContractLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.ContractView
  alias SuperIssuer.Contract

  def render(assigns) do
    ContractView.render("contract.html", assigns)
  end

  def mount(_params, %{
    "current_user_id" => 1
  }, socket) do

    changeset = Contract.changeset(%Contract{})
    {:ok,
    socket
    |> assign(changeset: changeset)
  }
  end

  def mount(_params, _, socket) do
    {:ok,
    socket
    |> redirect(to: "/")
  }
  end
  def handle_event("save", %{"contract" => contract}, socket) do
    contract = StructTranslater.to_atom_struct(contract)
    contract =
      contract
      |> Map.put(:init_params, Poison.decode!(contract.init_params))
    IO.puts inspect contract
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
