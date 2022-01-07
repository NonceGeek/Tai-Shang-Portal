# defmodule SuperIssuer.WeidDirectInteractor do
#   @moduledoc """
#     Directly Interact with Weid Contract.
#   """
#   alias SuperIssuer.ContractTemplate
#   alias SuperIssuer.Ethereum.EventLog

#   @con_template_name "WeIdContract"
#   @func %{
#     dele_set_attr: "delegateSetAttribute"
#   }

#   def get_abi() do
#     ContractTemplate.get_abi(@con_template_name)
#   end

#   def get_bin() do
#     ContractTemplate.get_bin(@con_template_name)
#   end

#   def dele_set_attr(chain, signer_addr, contract, %{params: [addr, key, value]}) do
#     evi_preloaded = Evidence.preload(evi)
#     updated = :os.system_time(:millisecond)
#     WeBaseInteractor.handle_tx(
#       chain,
#       signer_addr,
#       contract.addr,
#       @func.dele_set_attr,
#       [addr, key, value, updated],
#       get_abi()
#     )
#   end

# end
