defmodule SuperIssuer.ChainSyncer do
  @moduledoc """
    sync a chain data to local.
  """

  use GenServer
  require Logger

  alias SuperIssuer.Chain

  @pull_interval 60_000

  # +-----------+
  # | GenServer |
  # +-----------+

  def start_link(chain_name) do
    GenServer.start_link(__MODULE__, chain_name, name: :"#{chain_name}_syncer")
  end

  def init(chain_name) when is_nil(chain_name) do
    {:ok, :do_nothing}
  end

  def init(chain_name) do
    Logger.info("#{chain_name}")
    chain = Chain.get_by_name(chain_name)
    do_init(chain)
  end


  def do_init(chain) when is_nil(chain) do
    payload = "do_nothing"

    Logger.info(payload)
    {:ok, payload}
  end
  def do_init({:error, error_log}), do: {:ok, error_log}

  def do_init(chain) do
    chain = Chain.preload(chain)
    send(self(), :pull)
    {:ok, chain}
  end

  @spec schedule_pull :: reference
  def schedule_pull() do
    Process.send_after(self(), :pull, @pull_interval)
  end

  def handle_info(:pull, chain) do
    {:ok, chain} = sync_chain(chain)
    schedule_pull()
    {:noreply, chain}
  end

  ## ===

  def sync_chain(%{adapter: adapter_name} = chain) do
    Logger.info("syncing")
    adapter = :"Elixir.SuperIssuer.Chain.#{adapter_name}"
    {:ok, latest_height} = adapter.get_best_block_height(chain)
    height_now = Chain.get_height_now(chain)
    do_sync_chain(chain, adapter, latest_height, height_now)
    Chain.change(chain, %{height_now: latest_height})
  end

  def do_sync_chain(_chain, _adapter, latest_height, height_now)
  when latest_height == height_now do
    :pass
  end

  def do_sync_chain(chain, adapter, latest_height, height_now) do
    Enum.map(latest_height..(height_now + 1), fn height ->
        adapter.sync_block(chain, height)
      end)
  end

end
