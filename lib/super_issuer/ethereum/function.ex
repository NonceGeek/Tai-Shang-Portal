defmodule  SuperIssuer.Ethereum.Function do
  alias __MODULE__
  alias SuperIssuer.Ethereum.{Argument, ABI}
  @type t :: %Function{
    name: String.t(),
    inputs: list(Argument.t()),
    outputs: list(Argument.t()),
    signature: String.t(),
    signature_bytes: String.t()}
  defstruct [:name, :inputs, :outputs, :signature, :signature_bytes]

  def gen_sig_bytes(name, inputs) do
    hash =
      ABI.gen_sig(name, inputs)
      |> Crypto.keccak_256sum()
      |> String.downcase()
      |> String.slice(0, 8)

    "0x" <> hash
  end

end
