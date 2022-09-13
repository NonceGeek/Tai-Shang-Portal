defmodule Crypto do
  @moduledoc """
    Crypto Lib
  """

  @secret_key Application.get_env(:super_issuer, :secret_key)
  @iv Application.get_env(:super_issuer, :iv)
  def sha256(data), do: :crypto.hash(:sha256, data)
  def ripemd160(data), do: :crypto.hash(:ripemd160, data)
  def double_sha256(data), do: data |> sha256 |> sha256

  def secp256k1_verify(data, sig, pubkey) do
    :crypto.verify(:ecdsa, :sha256, data, sig, [pubkey, :secp256k1])
  end

  def secp256k1_sign(data, private_key) do
    :crypto.sign(:ecdsa, :sha256, data, [private_key, :secp256k1])
  end

  def generate_key_secp256k1() do
    {pubkey, privkey} = :crypto.generate_key(:ecdh, :secp256k1)

    if byte_size(privkey) != 32 do
      generate_key_secp256k1()
    else
      %{pub: pubkey, priv: privkey}
    end
  end

  def generate_key_secp256k1(private_key) do
    :crypto.generate_key(:ecdh, :secp256k1, private_key)
  end

  def keccak_256sum(data) do
    data
    |> kec()
    |> Base.encode16()
  end

  def kec(data) do
    ExSha3.keccak_256(data)
  end

  def encrypt_key(key) do
    encrypt_key(key, @secret_key)
  end

  def encrypt_key(key, password) do
    md5_pwd = md5(password)
    # :crypto.block_encrypt(:aes_ecb, md5_pwd, pad(key, 16))
    :crypto.crypto_one_time(:aes_256_cbc, md5_pwd, @iv, Crypto.pad(key, 16), true)
  end

  def decrypt_key(key) do
    decrypt_key(key, @secret_key)
  end
  def decrypt_key(encrypted_key, password) do
    md5_pwd = md5(password)

    :crypto.crypto_one_time(:aes_256_cbc, md5_pwd, @iv, encrypted_key, false)
    |> unpad()
  end

  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  def md5(data) do
    :md5
    |> :crypto.hash(data)
    |> Base.encode16(case: :lower)
  end

  # +-
  # | methods about Ethereum INPUT
  # +-

  @doc """
    > https://www.4byte.directory/ \n

    Function calls in the Ethereum Virtual Machine are specified by the first four bytes of data sent with a transaction. These 4-byte signatures are defined as the first four bytes of the Keccak hash (SHA3) of the canonical representation of the function signature. The database also contains mappings for event signatures. Unlike function signatures, they are defined as 32-bytes of the Keccak hash (SHA3) of the canonical form of the event signature. Since this is a one-way operation, it is not possible to derive the human-readable representation of the function or event from the bytes signature. This database is meant to allow mapping those bytes signatures back to their human-readable versions.

    Example: `claim(string,string)`
  """
  def gen_func_signature(function_sig_str) do
    do_gen_signature(function_sig_str, 4)
  end
  def gen_event_signature(event_sig_str) do
    do_gen_signature(event_sig_str, 32)
  end

  def do_gen_signature(payload, size) do
    payload
    |> Crypto.keccak_256sum()
    |> Base.decode16!
    |> Binary.take(size)
    |> Base.encode16(case: :lower)
  end
end
