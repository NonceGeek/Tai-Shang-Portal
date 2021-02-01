defmodule SuperIssuer.EvidenceHandler do
  @moduledoc """
    handle with Evidence Contract
  """
  alias SuperIssuer.Evidence

  @evi_bin FileHandler.read(:bin, "contract/evidence/evidence.bin")
  @evi_abi FileHandler.read(:json, "contract/evidence/evidence.abi")
  @func %{
    new_evi: "newEvidence",
    get_evi: "getEvidence",
    add_sig: "addSignatures"
  }


  def add_signatures(signer_addr, evi) do
    evi_preloaded = Evidence.preload(evi)
    WeBaseInteractor.handle_tx(
      signer_addr,
      evi_preloaded.contract.addr,
      @func.add_sig,
      [evi.key],
      @evi_abi
    )
  end

  def get_evidence(caller_addr, evi) do
    evi_preloaded = Evidence.preload(evi)
    WeBaseInteractor.handle_tx(
      caller_addr,
      evi_preloaded.contract.addr,
      @func.get_evi,
      [evi.key],
      @evi_abi
    )
  end

  def new_evidence(deployer_addr, contract_addr, evidence) do
    {:ok, %{"transactionHash" => tx_id, "logs" => logs}} =
      WeBaseInteractor.handle_tx(
        deployer_addr,
        contract_addr,
        @func.new_evi,
        [evidence],
        @evi_abi
      )
    key =
      logs
      |> Enum.fetch!(0)
      |> Map.get("address")
    {:ok, key, tx_id}
  end

  def deploy(deployer_addr, signer_list) do
    WeBaseInteractor.deploy(
      deployer_addr,
      @evi_bin,
      @evi_abi,
      [signer_list]
    )
  end

  def get_signers() do
  end
end
