defmodule SuperIssuerWeb.ContractLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.ContractView
  alias SuperIssuer.{User, Contract, Chain, ContractTemplate}

  def render(assigns) do
    ContractView.render("contract.html", assigns)
  end

  def mount(%{"contract_addr" => contract_addr}, _session, socket) do
    contract =
      contract_addr
      |> Contract.get_by_addr()
      |> Contract.preload()
    {:ok,
      socket
      |> assign(contracts: [contract])
      |> init_chain()
    }
  end

  def mount(%{"contract_id" => contract_id}, _session, socket) do
    contract =
      contract_id
      |> Contract.get_by_id()
      |> Contract.preload()
    {:ok,
      socket
      |> assign(contracts: [contract])
      |> init_chain()
    }
  end

  def mount(_params, _session, socket) do
    contracts =
      Contract.get_all()
      |> Enum.map(&(Contract.preload(&1)))
    {:ok,
      socket
      |> assign(contracts: contracts)
      |> init_chain()
    }
  end
  # def mount(_params, %{
  #   "current_user_id" => id
  # }, socket) do
  #   user = User.get_by_user_id(id)
  #   contracts =
  #     Contract.get_all()
  #     |> Enum.map(fn contract ->
  #       contract
  #       |> Map.put(:init_params, Poison.encode!(contract.init_params))
  #     end)
  #   {:ok,
  #     socket
  #     |> do_mount(user)
  #     |> assign(contracts: contracts)
  #     |> init_chain()
  #   }
  # end

  def init_chain(socket) do
    chains =
      Chain.get_all()
      |> Enum.map(fn %{id: id, name: name} ->
        {name, id}
      end)
      |> Enum.into(%{})
    types =
      ContractTemplate.get_all()
      |> Enum.map(fn %{id: id, name: name} ->
        {name, id}
      end)
      |> Enum.into(%{})
    socket
    |> assign(chains: chains)
    |> assign(types: types)
  end

  # def mount(_params, _, socket) do
  #   {:ok,
  #   socket
  #   |> redirect(to: "/")
  # }
  # end

  def do_mount(socket, %{group: 1}) do
    changeset = Contract.changeset(%Contract{})
    socket
    |> assign(changeset: changeset)
  end

  def do_mount(socket, _others) do
    socket
    |> redirect(to: "/")
  end

  def handle_event("save",
    %{
      "contract" =>
      %{
        "init_params" => init_params,
        "type" => c_tem_id,
        "the_chain" => chain_id,
        } = contract,
      } = payload,
    socket) do
    contract =
      contract
      |> StructTranslater.to_atom_struct()
      |> Map.put(:init_params, Poison.decode!(init_params))
      |> Map.put(:chain_id, String.to_integer(chain_id))
      |> Map.put(:contract_template_id, String.to_integer(c_tem_id))
      # |> Contract.handle()

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
  def handle_event("save", payload, socket) do
    IO.puts inspect payload
    {:noreply, socket}
  end
  def handle_event(_others, payload, socket) do
    {:noreply, socket}
  end

end
