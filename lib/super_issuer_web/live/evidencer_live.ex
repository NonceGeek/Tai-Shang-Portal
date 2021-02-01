defmodule SuperIssuerWeb.EvidencerLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.EvidencerView
  alias SuperIssuer.{Contract, Evidence, EvidenceHandler}
  alias SuperIssuer.Repo

  def render(assigns) do
    EvidencerView.render("evidencer.html", assigns)
  end

  def mount(_params, %{
    "current_user_id" => 1
  }, socket) do
    contracts =
      "Evidence"
      |> Contract.get_by_type()

    do_mount(contracts, socket)
  end

  def mount(_params, _, socket) do
    {:ok,
    socket
    |> redirect(to: "/")
    }
  end

  def do_mount([], socket) do
    {:ok,
      socket
      |> assign(form: :payloads)
      |> assign(contracts: nil)
      |> assign(signers: nil)
    }
  end

  def do_mount(contracts, socket) do
    IO.puts inspect socket.assigns
    contracts_des =
      contracts
      |> Enum.map(fn c->
        c.describe
      end)

    signers =
      contracts
      |> Enum.fetch!(0)
      |> get_evidence_signers()
    {:ok,
    socket
    |> assign(form: :payloads)
    |> assign(contracts: contracts_des)
    |> assign(signers: signers)
  }
  end

  @doc """
    it's only single now
  """
  def handle_event("up_to_chain", payloads, socket) do
    payloads
    |> StructTranslater.to_atom_struct()
    |> do_handle_event(socket)
  end

  def do_handle_event(%{
    payloads:
    %{
      contract: contract_des,
      data_load_to_chain: data,
      signer: signer,

    }
  }, socket) do
    contract = Contract.get_by_describe(contract_des)

    {:ok, key, tx_id} =
    EvidenceHandler.new_evidence(
      signer,
      contract.addr,
      data
    )
    IO.puts inspect tx_id
    {:ok, evi} =
      Repo.transaction(fn ->
        Evidence.create(%{
          key: key,
          tx_id: tx_id,
          value: data,
          owners: [signer],
          contract_id: contract.id,
          signers: [signer]
        })
      end)

    {:noreply,
    socket
    |> assign(evidence_info: data)
    |> put_flash("info_A", "up to chain!successfully")
    |> put_flash("info_B", "key: #{key}")
    }
  end

  def handle_event("change", %{
    "_target"=>  ["payloads", "contract"],
    "payloads" => %{
      "contract" => contract_des
    }
  }, socket) do

    contract = Contract.get_by_describe(contract_des)
    signers =
      get_evidence_signers(contract)

    {
      :noreply,
      socket
      |> assign(:signers, signers)
    }
  end


  def handle_event(sth, payload, socket) do
    {:noreply, socket}
  end

  def get_evidence_signers(contract) do
    contract
    |> Map.get(:init_params)
    |> Map.get("evidenceSigners")
  end
end
