defmodule SuperIssuerWeb.TxLive.Index do
    use SuperIssuerWeb, :live_view
    alias SuperIssuer.Tx

    @impl true
    def mount(%{"hash" => tx_hash}, _session, socket) do
      {:ok, init(socket, tx_hash)}
    end

    @impl true
    def handle_event(_key, _value, socket) do
      {:noreply, socket}
    end

    def init(socket, tx_hash) do
      tx =
        tx_hash
        |> Tx.get_by_hash()
        |> Tx.preload()

      assign(socket, tx: tx)
    end
  end
