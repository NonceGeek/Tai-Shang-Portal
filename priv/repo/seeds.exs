# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SuperIssuer.Repo.insert!(%SuperIssuer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias SuperIssuer.Chain
%{id: id} = Chain.create(%{
  adapter: "FiscoBcos"
  name: "WeLight",
  config: %{
    "webase" => "http://127.0.0.1:5002",
    "weid" => "http://127.0.0.1:6001"
  }
})

evidence_fac_abi =
  File.read!("contract/evidence/evidence_fac.abi")

erc20_abi =
  File.read!("contract/erc20/erc20.abi")

erc721_abi =
  File.read!("contract/erc721/erc721.abi")
alias SuperIssuer.ContractTemplate

%{id: evi_id} =
  ContractTemplate.create(%{
  name: "EvidenceFactory",
  abi: evidence_fac_abi
})

%{id: erc20_id} =
  ContractTemplate.create(%{
  name: "ERC20",
  abi: erc20_abi
})

%{id: erc_721_id} =
  ContractTemplate.create(%{
  name: "ERC721",
  abi: erc721_abi
})

alias SuperIssuer.Contract
Contract.create(%{
  chain_id: id,
  contract_template_id: evi_id,
  address: "TODO",
  init_params: %{
    "evidenceSigners" => ["0xbf1731dc34c4c6f9cb034b9386931318f365bda3",
     "0x0ca04d68d490fffbac15e38b018904f8222239ae"]
  },
  description: "柏链存证合约",
  creater: "TODO"
})
Contract.create(%{
  chain_id: id,
  contract_template_id: erc20_id,
  address: "TODO",
  init_params: %{
    "decimals" => 0,
    "governance" => "TODO=creater",
    "name" => "WeLightEnergy",
    "symbol" => "VLE"
  },
  description: "Erc20合约_VLE",
  creater: "TODO"
})
Contract.create(%{
  chain_id: id,
  contract_template_id: erc721_id,
  address: "TODO",
  init_params: %{
    "governance" => "TODO=creater",
    "name" => "WeLightNFT",
    "symbol" => "VLNFT"
  },
  description: "Erc721合约_VLNFT",
  creater: "TODO"
})
