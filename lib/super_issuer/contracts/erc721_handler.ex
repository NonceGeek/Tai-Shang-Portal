defmodule SuperIssuer.Contracts.Erc721Handler do
  @moduledoc """
    handle with Erc20 Contract
  """
  alias SuperIssuer.ContractTemplate

  @func %{
    name: "name",
    symbol: "symbol",
    balance_of: "balanceOf",
    total_supply: "totalSupply",
    owner_of: "ownerOf",
    token_uri: "tokenURI",
    mint_nft: "mintNft"
  }

  @con_template_name "Erc721"

  def get_abi() do
    ContractTemplate.get_abi(@con_template_name)
  end

  def get_bin() do
    ContractTemplate.get_bin(@con_template_name)
  end

  @doc """
    including name, symbol, decimals, governance
  """
  def get(param, chain, contract_str, caller_addr) do

    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_str,
      Map.get(@func, param),
      [],
      get_abi()
    )
  end

  @doc """
    mint nft
  """
  def mint_nft(chain, contract_addr, caller_addr, receiver_addr, uri) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_addr,
      @func.mint_nft,
      [receiver_addr, uri],
      get_abi()
    )
  end

  def get_token_owner(chain, contract_addr,  caller_addr, token_id) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_addr,
      @func.owner_of,
      [token_id],
      get_abi()
    )
  end

  def get_token_uri(chain, contract_addr,  caller_addr, token_id) do
    WeBaseInteractor.handle_tx(
      chain,
      caller_addr,
      contract_addr,
      @func.token_uri,
      [token_id],
      get_abi()
    )
  end
end
