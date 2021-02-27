defmodule SuperIssuer.AppCenter do

  def key_correct?(app, key) do
    app.encrypted_secret_key == Crypto.encrypt_key(key)
  end
  def has_permission?(app, contract) do
    contract.id in app.contract_id_list
  end

  def gen_key() do
    32
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end
end
