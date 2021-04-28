defmodule SuperIssuer.Chain.FiscoBcos do
  alias SuperIssuer.{Block, Tx, Event, Repo, Contract}

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
          payload ->
            payload
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
            build_event(addr, data, topics, height)
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
  end

  def build_event(addr, data, topics, height) do
    %Event{
      address: addr,
      data: data,
      topics: topics,
      block_height: height
    }
  end

end
