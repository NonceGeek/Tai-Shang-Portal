defmodule SuperIssuer.Contracts.EvidenceHandler do
  @moduledoc """
    handle with Evidence Contract
  """
  alias SuperIssuer.{Evidence, ContractTemplate}
  alias SuperIssuer.Ethereum.EventLog

  @func %{
    new_evi: "newEvidence",
    get_evi: "getEvidence",
    add_sig: "addSignatures",
    get_signers: "getSigners",
  }

  @con_template_name "Evidence"

  def get_abi() do
    ContractTemplate.get_abi(@con_template_name)
  end

  def get_bin() do
    ContractTemplate.get_bin(@con_template_name)
  end

  def new_evidence(chain, signer, contract, evidence) do
    {:ok, key, tx_id} =
      do_new_evidence(
        chain,
        signer,
        contract.addr,
        evidence
      )

    Evidence.create(%{
      key: key,
      tx_id: tx_id,
      value: evidence,
      owners: [signer],
      contract_id: contract.id,
      signers: [signer]
    })
  end
  def add_signatures(chain, signer_addr, evi) do
    evi_preloaded = Evidence.preload(evi)
    WeBaseInteractor.handle_tx(
      chain,
      signer_addr,
      evi_preloaded.contract.addr,
      @func.add_sig,
      [evi.key],
      get_abi()
    )
  end

  def get_evidence_on_chain(chain, caller_addr, evi) do
    evi_preloaded = Evidence.preload(evi)
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      evi_preloaded.contract.addr,
      @func.get_evi,
      [evi.key],
      get_abi()
    )
  end

  def do_new_evidence(chain, deployer_addr, contract_addr, evidence) do
    IO.puts deployer_addr
    IO.puts contract_addr
    {:ok, %{"transactionHash" => tx_id, "logs" => logs}} =
      WeBaseInteractor.handle_tx(
        chain,
        deployer_addr,
        contract_addr,
        @func.new_evi,
        [evidence],
        get_abi()
      )
    key =
      logs
      |> Enum.fetch!(0)
      |> Map.get("address")
    {:ok, key, tx_id}
  end

  def get_signers(chain, deployer_addr, contract_addr) do
    {:ok, [signer_list]} =
      WeBaseInteractor.handle_tx(
        chain,
        deployer_addr,
        contract_addr,
        @func.get_signers,
        [],
        get_abi()
      )
    {:ok, signer_list}
  end

  def deploy(chain, deployer_addr, signer_list) do
    WeBaseInteractor.deploy(
      chain,
      deployer_addr,
      get_bin(),
      get_abi(),
      [signer_list]
    )
  end

  def decode_event(%{
    data: data,
    topics: topics
  }) do
    EventLog.decode(get_abi(), topics, data)
  end

  def evi_valid?(evidence) do
    evi_handled =
      evidence
      |> String.replace("\'","\"")


    with {:ok, evi_decoded} <- Poison.decode(evi_handled),
      {:ok, did} <- Map.fetch(evi_decoded, "operator"),
      true <- do_did_valid?(did),
      {:ok, _app_id} <- Map.fetch(evi_decoded, "app_id") do
        :ok
      else
        _ ->
        :error
    end

  end

  def parse_evi(nil), do: %{}

  def parse_evi(evi) do
    evi_handled =
      evi
      |> String.replace("\'","\"")
    with {:ok, evi_decoded} <- Poison.decode(evi_handled) do
        evi_decoded
      else
        _ ->
        %{}
    end
  end

  def do_did_valid?(did) do
    did
    |> String.split(":")
    |> Enum.fetch!(0)
    |> Kernel.==("did")
  end
end
