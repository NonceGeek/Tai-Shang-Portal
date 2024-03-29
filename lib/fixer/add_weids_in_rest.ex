defmodule Fixer.AddWeidsInRest do
  alias SuperIssuer.WeIdentity
  alias SuperIssuer.Account
  alias SuperIssuerWeb.AppController

  def handle_weids() do
    "/home/ubuntu/weid-http-service/dist/keys/priv/*"
    |> FileHandler.fetch_files_in_path()
    |> Enum.reject(fn name -> name == "ecdsa_key" end)
    |> Enum.each(fn file_path ->
      priv = get_priv(file_path)
      addr =
        file_path
        |> String.split("/")
        |> Enum.fetch!(-1)
      weid = addr_to_weid(addr)

      weid
      |> WeIdentity.get_by_weid()
      |> handle_weid(priv, weid, addr)
    end)
  end

  def handle_weid(nil, priv, weid, addr) do

    # create weid_local
    {:ok, weidentity} =
      priv
      |> AppController.build_weid_params(weid)
      |> WeIdentity.create()

    # create account local
    handle_weid(weidentity, priv, weid, addr)
  end

  def handle_weid(%{id: weid_id}, priv, _weid, addr) do
    # create account local
    {:ok, _acct} =
      Account.create(%{weidentity_id: weid_id, addr: addr})

    chain = SuperIssuer.Chain.get_default_chain()
    user_name = AppController.generate_user_name("nil")
    priv_hex = Base.encode16(priv, case: :lower)
    {:ok, _addr} =
      WeBaseInteractor.create_account(chain, priv_hex, user_name)
    IO.puts "create account #{addr} ok!"
  end

  def get_priv(path) do
      hex_str =
        :bin
        |> FileHandler.read(path)
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

  @doc """
    attention! there is GROUP 1.
  """
  def addr_to_weid(addr), do: "did:weid:1:" <> addr
end
