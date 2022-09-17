defmodule SuperIssuerWeb.NftLive.Index do
    use SuperIssuerWeb, :live_view
    alias SuperIssuer.{Nft, Contract}

    @impl true
    def mount(%{"nft_contract_id" => contract_id, "addr" => addr}, _session, socket) do
      contract = %{id: id} =
        contract_id
        |> Contract.get_by_id()
        |> Contract.preload()
      nfts =
        contract
        |> Contract.preload()
        |> Map.get(:nfts)
        |> Enum.filter(fn %{owner: owner} ->
          String.downcase(owner) == String.downcase(addr)
        end)
      nft_num = Enum.count(nfts)
      {:ok, socket
      |> assign(contract: contract)
      |> assign(nft_num: nft_num)
      |> assign(nfts: nfts)}
    end

    @impl true
    def mount(%{"nft_contract_id" => contract_id}, _session, socket) do
      {:ok, init(socket, contract_id)}
    end

    @impl true
    def handle_event("search", %{"addr" => addr}, socket) do
      payload = Nft.check_owner(addr)
      do_handle_event(payload, addr, socket)

    end

    def handle_event(_key, _value, socket) do
      {:noreply, socket}
    end

    def do_handle_event(payload, _addr, socket) when is_nil(payload) do
      {
        :noreply,
        socket
        |> put_flash(:error, "this addr has not any SBT.")
      }
    end

    def do_handle_event(_payload, addr, socket) do
      {
        :noreply,
        socket
        |> redirect(to: Routes.addr_path(socket, :index, %{addr: addr}))
      }
    end

    def init(socket, contract_id) do
      contract = %{id: id} =
        contract_id
        |> Contract.get_by_id()
        |> Contract.preload()
      nft_num =
        Nft.count(id)

      nfts =
        contract
        |> Contract.preload()
        |> Map.get(:nfts)

      socket
      |> assign(contract: contract)
      |> assign(nft_num: nft_num)
      |> assign(nfts: nfts)
    end
  end
