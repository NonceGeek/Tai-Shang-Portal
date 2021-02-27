defmodule SuperIssuerWeb.AppController do
  alias SuperIssuer.{AppCenter, App, Contract, EvidenceHandler}
  use SuperIssuerWeb, :controller

  @resp_success %{
    "error_code" => 0,
    "error_msg" => "success",
    "result" => ""
  }

  @resp_failure %{
    "error_code" => 1,
    "error_msg" => "",
    "result" => ""
  }

  # +---------------+
  # | contracts api |
  # +---------------+
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
    contracts_info = get_contracts_info(contracts)
    json(conn, contracts_info)
  end

  def do_get_contracts({:error, info}, conn) do
    payload =
      @resp_failure
      |> Map.put("error_msg", info)
    json(conn, payload)
  end

  def get_contracts_info(contracts) do
    Enum.map(contracts, fn contract->
      funcs = Contract.get_funcs(contract)
      events = Contract.get_events(contract)
      %{}
      |> Map.put(:id, contract.id)
      |> Map.put(:init_params, contract.init_params)
      |> Map.put(:type,  contract.type)
      |> Map.put(:description, contract.description)
      |> Map.put(:funcs, funcs)
      |> Map.put(:events, events)
    end)
  end

  def interact_with_contract(conn, params) do
    params_struct =  StructTranslater.to_atom_struct(params)
    params_struct
    |> auth()
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
    try do

      case contract.type do
        "Evidence" ->
          case func_name do
            "newEvidence" ->
              {:ok, evi} =
                EvidenceHandler.new_evidence(
                  chain,
                  payload.signer,
                  contract,
                  payload.evidence)
              evi_struct = StructTranslater.struct_to_map(evi)
              payload =
                Map.put(@resp_success, :result, evi_struct)
              json(conn, payload)
          end
      end

    catch
      error ->
        payload =
          Map.put(@resp_failure, :result, inspect(error))
        json(conn, payload)
    end


  end

  def do_interact_with_contract({:error, info}, _params_struct, conn) do
    json(conn, %{error: info})
  end
end
