defmodule SuperIssuer.Contracts.WeLightLotteryHandler do
  @moduledoc """
    handle with WeLight Lottery Contract
  """
  alias SuperIssuer.ContractTemplate

  @func %{
    start_new_lottery: "startNewLottery",
    get_result: "getResult"
  }

  @con_template_name "WeLightLottery"

  def get_abi() do
    ContractTemplate.get_abi(@con_template_name)
  end

  def get_bin() do
    ContractTemplate.get_bin(@con_template_name)
  end

  def start_new_lottery(chain, contract_addr, caller_addr, total_num, prize_num, description) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_addr,
      @func.start_new_lottery,
      [total_num, prize_num, description],
      get_abi()
    )
  end

  def get_result(chain, contract_addr, caller_addr, request_id) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_addr,
      @func.get_result,
      [request_id],
      get_abi()
    )
  end
end
