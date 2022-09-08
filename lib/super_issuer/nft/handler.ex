defmodule SuperIssuer.Nft.Interactor do
  @moduledoc """
    Interactor for NFT/SBT
  """
  alias SuperIssuer.Nft.Parser
  @default_param_in_call "latest"
  @func %{
    token_uri: "tokenURI(uint256)"
  }

  def get_token_uri(%{config: %{"node" => node}} = _chain, contract_addr, token_id) do
    node
    |> do_get_token_uri(contract_addr, token_id)
    |> Parser.parse_token_uri()
  end

  def get_token_uri(%{config: %{"node" => node}} = _chain, contract_addr, token_id, :external_link) do
    node
    |> do_get_token_uri(contract_addr, token_id)
    |> Parser.parse_token_uri(:external_link)
  end

  def do_get_token_uri(endpoint, contract_addr, token_id) do
    data =
      get_data(
        @func.token_uri,
        [token_id]
      )

    data
    |> eth_call_repeat(contract_addr, @default_param_in_call, endpoint)
    |> TypeTranslator.data_to_str()
  end

  def eth_call_repeat(data, contract_addr, param, endpoint) do
    result =
      Ethereumex.HttpClient.eth_call(%{
      data: data,
      to: contract_addr
      }, param, url: endpoint)

    case result do
     {:ok, value} ->
        value
      {:error, :timeout} ->
        Process.sleep(1000) # wait 1 sec
        eth_call_repeat(data, contract_addr, param, endpoint)
    end
  end

  # +-------------+
  # | Basic Funcs |
  # +-------------+
  @spec get_data(String.t(), List.t()) :: String.t()
  def get_data(func_str, params) do
    payload =
      func_str
      |> ABI.encode(params)
      |> Base.encode16(case: :lower)

    "0x" <> payload
  end
end
