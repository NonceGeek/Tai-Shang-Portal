defmodule SuperIssuer.Chain.FiscoBcos do
  alias SuperIssuer.{Block, Tx, Event, Repo, Contract, Account, EventHandler, Event}
  alias SuperIssuer.Contracts.EvidenceHandler
  alias SuperIssuer.AccountEvent

  def get_best_block_height(chain) do
    WeBaseInteractor.get_block_number(chain)
  end

  def sync_block(chain, height) do
    {block_formatted, raw_txs} =
      chain
      |> WeBaseInteractor.get_block_by_number(height)
      |> handle_block(chain)

    txs_formatted =
      raw_txs
      |> handle_txs(chain, height)
      |> filter_txs()
    Repo.transaction(fn ->
      res =
        block_formatted
        |> Map.put(:tx, txs_formatted)
        |> Repo.insert()
      case res do
        {:error, payload} ->
          # error handler
            Repo.rollback("reason: #{inspect(payload)}")
          {:ok, block} ->
            handle_events_in_block(block)
      end
    end)


  end

  def handle_block({:ok, raw_block}, chain) do
    raw_block
    |> StructTranslater.to_atom_struct()
    |> do_handle_block(chain)
  end

  def do_handle_block(%{number: block_height, hash: block_hash, transactions: txs, timestamp: timestamp}, %{id: chain_id}) do
    timestamp_handled = handle_timestamp(timestamp)
    block_formatted =
      block_height
      |> build_block(block_hash, chain_id, timestamp_handled)
    {block_formatted, txs}
  end

  def handle_timestamp(timestamp) when is_binary(timestamp), do: String.to_integer(timestamp)
  def handle_timestamp(timestamp), do: timestamp
  def build_block(block_height, block_hash, chain_id, timestamp) do
    %Block{
      block_height: block_height,
      block_hash: block_hash,
      chain_id: chain_id,
      timestamp: timestamp
    }
  end

  def handle_txs(txs, chain, height) do
    Enum.map(txs, fn %{hash: tx_hash} ->
      chain
      |> WeBaseInteractor.get_transaction_receipt(tx_hash)
      |> handle_receipt(height)
    end)
  end

  def filter_txs(txs) do
    contracts_local = Contract.get_all()
    txs
    # set contract_id of every tx
    |> Enum.map(fn tx ->
      contract_id = get_contract_id_of_tx(tx, contracts_local)
      Map.put(tx, :contract_id, contract_id)
    end)
    # eject the nil tx
    |> Enum.reject(fn %{contract_id: c_id} ->
      is_nil(c_id)
    end)
  end

  def get_contract_id_of_tx(%{from: from, to: to}, contracts) do
    contracts
    |> Enum.find(fn %{addr: addr} ->
      (addr == from) or (addr == to)
    end)
    |> case do
      nil ->
        nil
      c ->
        c.id
    end
  end

  def handle_receipt({:ok, raw_tx_receipt}, height) do
    raw_tx_receipt
    |> StructTranslater.to_atom_struct()
    |> do_handle_receipt(height)
  end
  def do_handle_receipt(%{from: from_addr, to: to_addr, transactionHash: tx_hash, logs: logs}, height) do
    tx = build_tx(from_addr, to_addr, tx_hash)
    events =
      Enum.map(logs, fn payload ->
        case payload do
          %{address: addr, data: data, topics: topics, logIndex: log_index} ->
            build_event(addr, data, topics, height, log_index)
          %{address: addr, data: data, topics: topics} ->
            build_event(addr, data, topics, height, nil)
        end
      end)
    Map.put(tx, :event, events)
  end

  def build_tx(from, to, tx_hash) do
    %Tx{
      from: from,
      to: to,
      tx_hash: tx_hash
    }
  end

  def build_event(addr, data, topics, height, log_index) do
      %Event{
      address: addr,
      data: data,
      topics: topics,
      log_index: log_index,
      block_height: height
    }

    # event_parsed =  EventHandler.handle_event_by_contract(basic_event)
    # basic_event
    # |> handle_ele_in_event(event_parsed, :nft)
    # |> handle_ele_in_event(event_parsed, :addr)
    # |> handle_ele_in_event(event_parsed, :weid)
    # |> handle_ele_in_event(event_parsed, :acct)
  end

  def handle_events_in_block(%{tx: txs}) do
    Enum.map(txs, fn tx ->
      Enum.map(tx.event, fn event->
        event_parsed =  EventHandler.handle_event_by_contract(event)
        updated_eles =
          %{}
          |> handle_ele_in_evi(event_parsed, :nft)
          |> handle_ele_in_evi(event_parsed, :contract_addr)
          |> handle_ele_in_evi(event_parsed, :operator)
          |> handle_ele_in_evi(event_parsed, :weid)

        {:ok, event} = Event.change(event, updated_eles)

        handle_ele_in_event(event, event_parsed, :acct)

      end)
    end)
  end

  # +-------------+
  # | Evi Handler |
  # +-------------+
  def handle_ele_in_evi(updated_eles, %{obvious_event: %{args: args}} , ele) do
    # handle_by_the_rules
    evi =
      args
      |> Map.get("evi")
      |> EvidenceHandler.parse_evi()
    do_handle_ele_in_evi(updated_eles, evi, ele)
  end

  def do_handle_ele_in_evi(updated_eles, evi, ele) when is_map(evi) do
    key =
      "ref_"
      |> Kernel.<>(Atom.to_string(ele))
      |> String.to_atom()
    value = Map.get(evi, Atom.to_string(ele))
    Map.put(updated_eles, key, value)
  end

  def do_handle_ele_in_evi(updated_eles, _evi, _), do: updated_eles


  # +---------------+
  # | Event Handler |
  # +---------------+
  def handle_ele_in_event(event, %{obvious_event: %{args: args}}, :acct) do
    from_addr =  Map.get(args, "from")
    to_addr = Map.get(args, "to")
    with true <- not is_nil(from_addr),
      true <- not is_nil(to_addr) do
        do_handle_ele_in_event(event, [from_addr, to_addr], :acct)
    else
      _ ->
        nil
    end
  end

  def do_handle_ele_in_event(%{id: event_id}, addr_list, ele) when ele == :acct do
    Enum.map(addr_list, fn addr ->
      acct = Account.get_by_addr(addr)
      if is_nil(acct) do
        nil
      else
        AccountEvent.create(%{account_id: acct.id, event_id: event_id})
      end
    end)
  end

end
