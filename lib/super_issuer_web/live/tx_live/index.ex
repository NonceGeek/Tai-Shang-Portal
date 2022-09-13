defmodule SuperIssuerWeb.TxLive.Index do
    use SuperIssuerWeb, :live_view
    alias SuperIssuer.Tx

    @impl true
    def mount(%{"tx_id" => tx_id}, _session, socket) do
      {:ok, init(socket, tx_id)}
    end

    @impl true
    def handle_event(_key, _value, socket) do
      {:noreply, socket}
    end

    def init(socket, tx_id) do
      tx =
        tx_id
        |> Tx.get_by_hash()
        |> Tx.preload()

      assign(socket, tx: tx)
    end
  end
