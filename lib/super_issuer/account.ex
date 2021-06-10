defmodule SuperIssuer.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias SuperIssuer.{Contract, WeIdentity}
  alias SuperIssuer.Contracts.{Erc20Handler, Erc721Handler}
  alias SuperIssuer.Account
  alias SuperIssuer.Repo
  alias SuperIssuer.Account, as: Ele

  require Logger

  schema "account" do
    field :addr, :string
    field :ft_balance, :map
    field :nft_balance, :map

    belongs_to :weidentity, WeIdentity
    timestamps()
  end

  def fetch_addr_by_weid(weid) do
    weid
    |> String.split(":")
    |> Enum.fetch!(-1)
  end

  # +---------------+
  # | Account Funcs |
  # +---------------+

  # PS: get_ft_info: call the get_contract_info in Contract

  def get_ft_balance(chain, %{addr: erc_20_addr}  = erc_20_contract, caller_addr, query_addr) do
    {:ok, [ft_new_balance]} =
      Erc20Handler.get_balance(chain, erc_20_addr, caller_addr, query_addr)

    {:ok, _ele} = sync_to_local(erc_20_contract, query_addr, ft_new_balance)
    {:ok, ft_new_balance}
  end

  def sync_to_local(erc_20_contract, query_addr, ft_new_balance) do
    acct = Ele.get_by_addr(query_addr)
    do_sync_to_local(erc_20_contract, query_addr, acct, ft_new_balance)
  end

  defp do_sync_to_local(_erc_20_contract, query_addr, acct, _ft_new_balance)
    when is_nil(acct) do
    Logger.info("#{query_addr} is not in our Account List")
    {:ok, :pass}
  end

  defp do_sync_to_local(%{addr: erc_20_addr}, _query_addr, acct, ft_new_balance) do
    update_ft_balance(erc_20_addr, acct, ft_new_balance)
  end

  def update_ft_balance(
    erc20_addr,
    %{ft_balance: ft_balance_local} = acct,
    ft_new_balance)
  when is_nil(ft_balance_local) do
    do_update_ft_balance(erc20_addr, acct, %{}, ft_new_balance)
  end

  def update_ft_balance(
    erc20_addr,
    %{ft_balance: ft_balance_local} = acct,
    ft_new_balance) do
      do_update_ft_balance(erc20_addr, acct, ft_balance_local, ft_new_balance)
  end

  def do_update_ft_balance(erc20_addr, acct, ft_balance_local, ft_new_balance) do
    payload = Map.put(ft_balance_local, erc20_addr, ft_new_balance)
    Ele.change(acct, %{ft_balance: payload})
  end

  def update_nft_balnace(_erc721_addr, acct, token_id, _token_uri)
  when is_nil(acct) do
    Logger.info("#{token_id}'s owner is not in our Account List")
    {:ok, :pass}
  end

  def update_nft_balnace(erc721_addr, %{nft_balance: nft_balance} = acct, token_id, token_uri)
    when is_nil(nft_balance) do
    do_update_nft_balance(erc721_addr, %{}, acct, token_id, token_uri)
  end

  def update_nft_balnace(erc721_addr, %{nft_balance: nft_balance} = acct, token_id, token_uri) do
    do_update_nft_balance(erc721_addr, nft_balance, acct, token_id, token_uri)
  end

  def do_update_nft_balance(erc721_addr, nft_balance, acct, token_id, token_uri) do
    balance_of_the_token =  Map.get(nft_balance, erc721_addr)
    balance_of_the_token =
      if is_nil(balance_of_the_token) do
        %{}
      else
        balance_of_the_token
      end

    balance_of_the_token_newest = Map.put(balance_of_the_token,  token_id, token_uri)
    payload = Map.put(nft_balance, erc721_addr, balance_of_the_token_newest)
    Ele.change(acct, %{nft_balance: payload})
  end

  def transfer_ft(chain, %{addr: erc_20_addr} = contract, from, to, amount) do
    {:ok, ft_balance} = get_ft_balance(chain, %{addr: erc_20_addr}, from, from)
    with {:ok, :pos} <- check_amount_pos(amount),
      {:ok, :balance_enough} <- checkout_balance_enough(ft_balance, amount) do
        # Ensure Transfer is Ok
        {:ok,
         %{
           "statusOK" => true,
           "transactionHash" => tx_id
           }}  = payload = Erc20Handler.transfer(chain, erc_20_addr, from, to, amount)
        IO.puts inspect payload

        # Update the balance
        Task.async(fn ->
          # eazy way suit now!
          :timer.sleep(3000)
          {:ok, from_balance} = get_ft_balance(chain, contract, from, from)
          {:ok, to_balance} = get_ft_balance(chain, contract, to, to)
          Logger.info("#{from} balance is #{from_balance} now")
          Logger.info("#{to} balance is #{to_balance} now")
        end)
        # {:ok, %Account{}} = sync_to_local(contract, from, ft_balance - amount)
        # sync_to_local(contract, to, ft_balance + amount)
        {:ok, tx_id}
    else
      error_info ->
        error_info
    end
  end

  def get_nft_balance(chain, %{addr: contract_addr, erc721_total_num: local_supply} = erc_721_contract, caller_addr, query_addr) do

    {:ok, [total_supply]} =  Erc721Handler.get(:total_supply, chain, contract_addr, caller_addr)
    sync_nfts(chain, local_supply, total_supply, contract_addr, caller_addr)

    # update total_supply
    Contract.change(erc_721_contract, %{erc721_total_num: total_supply})

    # get_addr's all nft
    %{nft_balance: nft_balance} =
      query_addr
      |> get_by_addr()
      |> handle_nil()
    {:ok, nft_balance}
  end

  def handle_nil(payload) when is_nil(payload) do
    %{nft_balance: []}
  end

  def handle_nil(payload), do: payload

  def sync_nfts(_chain, local_supply, total_supply, _contract_addr, _caller_addr) when local_supply == total_supply, do: :pass

  def sync_nfts(chain, local_supply, total_supply, contract_addr, caller_addr) when is_nil(local_supply) do
    sync_nfts(chain, 0, total_supply, contract_addr, caller_addr)
  end
  def sync_nfts(chain, local_supply, total_supply, contract_addr, caller_addr) do
   Enum.map((local_supply + 1)..total_supply, fn token_id ->
    {:ok, %{owner_addr: owner_addr, token_uri: token_uri}} =
      sync_nft(chain, token_id, contract_addr, caller_addr)

    acct = get_by_addr(owner_addr)

    {:ok, _ele} = update_nft_balnace(contract_addr, acct, token_id, token_uri)
   end)
  end

  def sync_nft(chain, token_id, contract_addr, caller_addr) do
    {:ok, [owner_addr]} = Erc721Handler.get_token_owner(chain, contract_addr, caller_addr, token_id)
    {:ok, [token_uri]} = Erc721Handler.get_token_uri(chain, contract_addr, caller_addr, token_id)
    {:ok, %{owner_addr: owner_addr, token_uri: token_uri}}
  end

  def check_amount_pos(amount) do
    if amount > 0 do
      {:ok, :pos}
    else
      {:error, :neg_amount}
    end
  end

  def checkout_balance_enough(ft_balance, amount) do
    if ft_balance >= amount do
      {:ok, :balance_enough}
    else
      {:erro, :balance_not_enough}
    end
  end

  # +----------------+
  # | Database Funcs |
  # +----------------+
  def preload(ele) do
    Repo.preload(ele, :weidentity)
  end

  def get_all() do
    Repo.all(Ele)
  end

  def get_by_addr(addr) do
    Repo.get_by(Ele, addr: addr)
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def change(%Ele{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Ele{} = ele) do
    Ele.changeset(ele, %{})
  end

  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:addr, :weidentity_id, :ft_balance, :nft_balance])
  end
end
