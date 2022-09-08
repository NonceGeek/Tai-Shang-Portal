defmodule Crypto do
  @moduledoc """
    Crypto Lib
  """

  @secret_key Application.get_env(:super_issuer, :secret_key)

  def sha256(data), do: :crypto.hash(:sha256, data)
  def ripemd160(data), do: :crypto.hash(:ripemd160, data)
  @spec double_sha256(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            )
        ) :: binary
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

  @spec encrypt_key(
          binary,
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            )
        ) :: any
  def encrypt_key(key, password) do
    md5_pwd = md5(password)
    :crypto.public_encrypt(:aes_ecb, md5_pwd, pad(key, 16), true)
  end

  def decrypt_key(key) do
    decrypt_key(key, @secret_key)
  end
  def decrypt_key(encrypted_key, password) do
    md5_pwd = md5(password)

    :aes_ecb
    |> :crypto.public_decrypt(md5_pwd, encrypted_key)
    |> unpad()
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  defp md5(data) do
    :md5
    |> :crypto.hash(data)
    |> Base.encode16(case: :lower)
  end
end
