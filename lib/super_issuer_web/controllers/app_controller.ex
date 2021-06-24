defmodule SuperIssuerWeb.AppController do
  alias SuperIssuer.{WeIdentity, AppCenter, App, Chain, Contract, ContractTemplate, WeidInteractor}
  alias SuperIssuer.Contracts.EvidenceHandler
  alias SuperIssuer.{Account, Repo}
  use SuperIssuerWeb, :controller

  @weid_rest_service_path Application.get_env(:super_issuer, :weid_rest_service_path)

  @resp_success %{
    error_code: 0,
    error_msg: "success",
    result: ""
  }

  @resp_failure %{
    error_code: 1,
    error_msg: "",
    result: ""
  }

  # +---------------+
  # | contracts api |
  # +---------------+

  @doc """
    [api]/contracts
  """
  def get_contracts(conn, params) do
    params
    |> StructTranslater.to_atom_struct()
    |> auth()
    |> do_get_contracts(conn)
  end

  def auth(%{app_id: id, secret_key: secret_key}) do
    with {:ok, app} <- App.handle_result(App.get_by_id(id)),
        true <- AppCenter.key_correct?(app, secret_key) do
        {:ok, app}
    else
      _ ->
        {:error, "incorrect app_id or secret_key"}
    end
  end
  def do_get_contracts({:ok, %{contracts: contracts}}, conn) do
    contracts_info = Contract.get_contracts_info(contracts)
    json(conn, contracts_info)
  end

  def do_get_contracts({:error, info}, conn) do
    payload =
      @resp_failure
      |> Map.put(:error_msg, info)
    json(conn, payload)
  end

  @doc """
    [api]/contract/func
  """
  def interact_with_contract(conn, params) do
    params_struct =  StructTranslater.to_atom_struct(params)
    params_struct
    |> auth()
    # |> has_contract_permission?(params_struct)
    |> do_interact_with_contract(params_struct, conn)
  end

  def do_interact_with_contract(
    {:ok, _app},
    %{contract_id: c_id, func: func_name, params: payload},
    conn) do
    # TODO: 优化
    %{chain: chain}
      = contract
      = c_id
        |> Contract.get_by_id()
        |> Contract.preload()
    payload_res =
      get_payload(chain, contract, func_name, payload)

    json(conn, payload_res)
  end

  def do_interact_with_contract({:error, info}, _params_struct, conn) do
    json(conn, %{error: info})
  end

  def get_payload(chain, contract, func_name, payload) do
    try do
      case contract.contract_template.name do
        "Evidence" ->
          case func_name do
            "newEvidence" ->
              new_evi(chain, contract, payload)
          end
      end
    catch
      error ->
        Map.put(@resp_failure, :result, inspect(error))
    end
  end

  def new_evi(
    chain,
    contract,
    %{
      evidence: evi,
      signer: signer
    }) do
    with :ok <- EvidenceHandler.evi_valid?(evi) do

      {:ok, evi} =
        EvidenceHandler.new_evidence(
          chain,
          signer,
          contract,
          evi)
      evi_struct = StructTranslater.struct_to_map(evi)
      Map.put(@resp_success, :result, evi_struct)
    else
      _ ->
      Map.put(@resp_failure, :result, "evidence is not regular")
    end
  end

  # +----------+
  # | weid api |
  # +----------+

  def create_weid(conn, params) do
    params_struct =
      params
      |> StructTranslater.to_atom_struct()

    params_struct
    |> auth()
    |> has_weid_permission?()
    |> do_create_weid(params_struct, conn)
  end

  def has_weid_permission?({:ok, %{weid_permission: 1} = app}) do
    {:ok, app}
  end
  def has_weid_permission?({:ok, %{weid_permission: _others}}) do
    {:error, "this app is not allowed to use weid"}
  end
  def has_weid_permission?(others), do: others

  def do_create_weid({:ok, %{id: app_id}}, %{chain_id: chain_id}, conn) do
    chain = Chain.get_by_id(chain_id)
    {:ok, weid} = WeidInteractor.create_weid(chain)

    # get weid in weid rest_service
    priv_key = fetch_priv_bin(weid)

    result =
      Repo.transaction(fn ->
        try do
          {:ok, %{id: weid_id, weid: weid}} =
            priv_key
            |> build_weid_params(weid)
            |> WeIdentity.create()

          addr = Account.fetch_addr_by_weid(weid)
          # # create account local
          {:ok, _acct} =
            Account.create(%{weidentity_id: weid_id, addr: addr})
          user_name = generate_user_name(app_id)

          priv_hex = Base.encode16(priv_key, case: :lower)
          {:ok, _addr} =
            WeBaseInteractor.create_account(chain, priv_hex, user_name)

          {:ok, weid}

          rescue
            error ->
              error_str = inspect(error)
              Repo.rollback("reason: #{error_str}")
              {:error, error_str}
        end
      end)

    case result do
      # transaction ok and weid stream ok
      {:ok, {:ok, weid}} ->

        payload = Map.put(@resp_success, :result, weid)
        json(conn, payload)
      {:error, error_str} ->
        handle_error({:error, error_str}, conn)
    end


  end

  def do_create_weid({:error, info}, params_struct, conn) do
    handle_error({:error, info}, params_struct, conn)
  end

  def fetch_priv_bin(weid) do
    hex_str =
      weid
      |> fetch_priv(@weid_rest_service_path)
      # to binary
      |> String.to_integer()
      |> Integer.to_string(16)


    case byte_size(hex_str) do
      63 ->
        "0"
        |> Kernel.<>(hex_str)
        |> Base.decode16!()
      _ ->
        Base.decode16!(hex_str)
    end
  end

  def build_weid_params(priv, weid) do
    # get priv from weid-rest-service
    %{weid: weid, type: "LocalWeidRestService", encrypted_privkey: priv}
  end

  @spec fetch_priv(binary, binary) :: binary
  def fetch_priv(weid, weid_rest_service_path) do
    file_name = Account.fetch_addr_by_weid(weid)
    full_path = weid_rest_service_path <>(file_name)
    FileHandler.read(:bin, full_path)
  end

  def generate_user_name(app_id) do
    timestamp_mil = RandGen.get_timestamp()
    rand_num = RandGen.gen_hex(8)

    "#{app_id}_#{timestamp_mil}_#{rand_num}"
  end


  # +-----------+
  # | token api |
  # +-----------+

  def get_ft_balance(conn, params) do
    params_structed =
      params
      |> StructTranslater.to_atom_struct()

      params_structed
      |> auth()
      |> do_get_ft_balance(params_structed, conn)
  end

  def do_get_ft_balance({:ok, _app},
    %{token_addr: token_addr, addr: addr},
    conn) do
      %{chain: chain} =
        contract =
          token_addr
          |> Contract.get_by_addr()
          |> Contract.preload()

    {:ok, balance} =
      Account.get_ft_balance(chain, contract, addr, addr)
    payload =
      Map.put(@resp_success, :result, %{balance: balance})
    json(conn, payload)
  end

  def do_get_ft_balance(app_info, params, conn) do
    handle_error(app_info, params, conn)
  end


  def transfer_ft(conn, params) do
    params_structed =
      params
      |> StructTranslater.to_atom_struct()

      params_structed
      |> auth()
      |> do_transfer_ft(params_structed, conn)
  end

  def do_transfer_ft({:ok, _app},
  %{
    token_addr: token_addr,
    from: from,
    to: to,
    amount: amount},
  conn) do
    %{chain: chain} =
      contract =
        token_addr
        |> Contract.get_by_addr()
        |> Contract.preload()
    case Account.transfer_ft(chain, contract, from, to, amount) do
      {:ok, tx_id} ->
        payload =
          Map.put(@resp_success, :result, %{tx_id: tx_id})
        json(conn, payload)
      {:error, info} ->
        handle_error({:error, info}, conn)
    end
  end

  def do_transfer_ft(app_info, params, conn) do
    handle_error(app_info, params, conn)
  end

  def get_nft_balance(conn, params) do
    params_structed =
      params
      |> StructTranslater.to_atom_struct()

    do_get_nft_balance(params_structed, conn)
  end

  def do_get_nft_balance(%{token_addr: token_addr, addr: addr}, conn) do
    %{chain: chain} =
      contract =
        token_addr
        |> Contract.get_by_addr()
        |> Contract.preload()
    case Account.get_nft_balance(chain, contract, addr, addr) do
      {:ok, nft_balance} ->
        reorged_nft_balance = re_org_nft_balance(nft_balance)
        payload = Map.put(@resp_success, :result, %{balance: reorged_nft_balance})
        json(conn, payload)
      {:error, error_info} ->
        handle_error({:error, error_info}, conn)
    end

  end

  def re_org_nft_balance(nft_balance) do
    Enum.map(nft_balance, fn {token_addr, tokens} ->
      reorged_tokens = re_org_nft_tokens(tokens)
      %{
        token_addr: token_addr,
        tokens: reorged_tokens
      }
    end)
  end

  def re_org_nft_tokens(tokens) do
    Enum.map(tokens, fn {token_id, token_uri} ->
      %{
        token_id: token_id,
        token_uri: token_uri
      }
    end)
  end
  def handle_error({:error, info}, conn) do
    payload =
      @resp_failure
      |> Map.put(:error_msg, info)
    json(conn, payload)
  end

  def handle_error({:error, info}, _params, conn) do
    payload =
      @resp_failure
      |> Map.put(:error_msg, info)
    json(conn, payload)
  end


end
