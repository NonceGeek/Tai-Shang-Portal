defmodule SuperIssuer.EvidenceHandler do
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

  def get_abi() do
    "Evidence"
    |> ContractTemplate.get_by_name()
    |> Map.get(:abi)
  end

  def get_bin() do
    "Evidence"
    |> ContractTemplate.get_by_name()
    |> Map.get(:bin)
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
end
