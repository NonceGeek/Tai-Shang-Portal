defmodule SuperIssuer.Chain.Venachain do

  alias SuperIssuer.{Block, Tx, Event, Repo, Contract, EventHandler, Event}
  alias Ethereumex.HttpClient
  alias SuperIssuer.Nft
  alias SuperIssuer.Nft.Interactor

  require Logger

  def get_best_block_height(%{config: %{"node" => node}} = _chain) do
    {:ok, raw_height} = HttpClient.eth_block_number([url: node])
    {:ok, TypeTranslator.hex_to_int(raw_height)}
  end

  def sync_block(%{config: %{"node" => node}} = chain, height) do
    {block_formatted, raw_txs} =
      height
      |> TypeTranslator.int_to_hex()
      |> HttpClient.eth_get_block_by_number(true, [url: node])
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
            handle_events_in_block(block, chain)
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

  def handle_timestamp(timestamp) do
    timestamp
    |> Binary.drop(2)
    |> String.to_integer(16)
  end
  def build_block(block_height, block_hash, chain_id, timestamp) do
    %Block{
      block_height: TypeTranslator.hex_to_int(block_height),
      block_hash: block_hash,
      chain_id: chain_id,
      timestamp: timestamp
    }
  end

  # Tx Funcs
  def handle_txs(txs, %{config: %{"node" => node}} = _chain, height) do
    Logger.info("syncing block: #{height}")
    Enum.map(txs, fn tx ->
      tx_hash = tx_to_hash(tx)
      Logger.info("tx_hash: #{tx_hash}")
      tx_hash
      |> HttpClient.eth_get_transaction_receipt([url: node])
      |> handle_receipt(height)
    end)
  end

  def tx_to_hash(tx) when is_binary(tx), do: tx
  def tx_to_hash(tx) do
    %{hash: hash} = tx
    hash
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
      log_index: TypeTranslator.hex_to_int(log_index),
      block_height: height
    }
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

  def handle_events_in_block(%{tx: txs}, chain) do
    Enum.map(txs, fn tx ->
      Enum.map(tx.event, fn event->
        event
        |> EventHandler.handle_event_by_contract()
        |> handle_event(tx, chain)
      end)
    end)
  end

  def handle_event(%{obvious_event: obvious_event}, tx, chain) do
    do_handle_event(obvious_event, tx, chain)
  end

  @doc """
    oh it's an nft transfer
  """
  def do_handle_event(%{args: %{"from" => from, "to" => to, "tokenId" => token_id}, event: %{name: "Transfer"}}, tx, chain) do
    Logger.info("an nft is transfer from #{from} to #{to} with #{token_id}")
    # update nft status
    %{contract: %{id: id} = contract} = Tx.preload(tx)
    nft = Nft.get_by_token_id_and_contract_id(token_id, id)
    update_nft(nft, token_id, to, contract, chain)
  end

  @doc """
    generate an new nft or update the existed nft
  """
  def update_nft(nil, token_id, to, %{addr: addr, id: id} = _contract, chain) do
    uri = Interactor.get_token_uri(chain, addr, token_id, :external_link)
    Nft.create(%{uri: uri, token_id: token_id, owner: to, contract_id: id})
  end

  def update_nft(nft, _token_id, to, _contract, _chain) do
    Nft.update(nft, %{owner: to})
  end

end
