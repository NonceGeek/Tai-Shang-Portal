alias SuperIssuer.WeIdentity
alais SuperIssuerWeb.AppController
@weid_rest_service_path "todo"

def handle_weids() do
  @weid_rest_service_path
  |> FileHandler.fetch_files_in_path()
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
    |> App.build_weid_params(weid)
    |> WeIdentity.create()

  handle_weid(weidentity, addr)

end

def handle_weid(%{id: weid_id, weid: weid}, addr) do
  # create account local
  {:ok, _acct} =
    Account.create(%{weidentity_id: weid_id, addr: addr})
end

def get_priv(path) do
  hex_str
    path
    |> FileHandler.read()
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
