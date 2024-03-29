defmodule SuperIssuer.Contracts.Erc20Handler do
  @moduledoc """
    handle with Erc20 Contract
  """
  alias SuperIssuer.ContractTemplate

  @func %{
    name: "name",
    symbol: "symbol",
    decimals: "decimals",
    governance: "governance",
    transfer: "transfer",
    balance_of: "balanceOf",
    mint: "mint"
  }

  @con_template_name "Erc20"

  def get_abi() do
    ContractTemplate.get_abi(@con_template_name)
  end

  def get_bin() do
    ContractTemplate.get_bin(@con_template_name)
  end

  @doc """
    including name, symbol, decimals, governance
  """
  def get(param, chain, erc_20_contract_str, caller_addr) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      erc_20_contract_str,
      Map.get(@func, param),
      [],
      get_abi()
    )
  end

  def get_balance(chain, erc_20_contract_str, caller_addr, query_addr) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      erc_20_contract_str,
      @func.balance_of,
      [query_addr],
      get_abi()
    )
  end

  def transfer(chain, erc_20_contract_str, from, to, amount) do
    WeBaseInteractor.handle_tx(
      chain,
      from,
      erc_20_contract_str,
      @func.transfer,
      [to, amount],
      get_abi()
    )
  end
end
