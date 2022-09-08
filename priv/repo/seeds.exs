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

# init chain
alias SuperIssuer.Chain
{:ok, %{id: id}} = Chain.create(%{
    adapter: "Venachain",
    name: "Venachain",
    config: %{
      "node" => "http://127.0.0.1:6791"
    }
  })

alias SuperIssuer.{ContractTemplate, Contract}


# add contract templates & contract
c_t = %{
  name: "soul_card_sbt",
  abi: Poison.decode!(File.read!("contracts/soulcard/SoulCard.abi")),
  source_code: File.read!("contracts/soulcard/SoulCard.sol"),
}
{:ok, %{id: c_id}} = ContractTemplate.create(c_t)
c = %{
  contract_template_id: c_id,
  chain_id: id,
  # addr: "0x545edf91e91b96cfa314485f5d2a1757be11d384", # local
  addr: "0x8b8af2bb13f8907de07ee94db76ff4980a7314fd", # 210
  creater: "0xbc98fff44b9de6957515c809d5a17e311987444a",
  description: "SoulCard, web3 namecard focus on buidlers"
}
Contract.create(c)

c_3 = %{
  contract_template_id: c_id,
  chain_id: id,
  addr: "0xf415aa9df3595797f74a753baeb1b831a316caaf", # 210
  creater: "0xbc98fff44b9de6957515c809d5a17e311987444a",
  description: "DAOSoulCard, web3 namecard focus on Orgs."
}
Contract.create(c)

c_t_2 = %{
  name: "did",
  abi: Poison.decode!(File.read!("contracts/did/EthereumDIDRegistry.abi")),
  source_code: File.read!("contracts/did/EthereumDIDRegistry.sol"),
}

{:ok, %{id: c_id_2}} = ContractTemplate.create(c_t_2)

c_2 = %{
  contract_template_id: c_id_2,
  chain_id: id,
  addr: "0xa2f3f3f3bcf24a10e8c3b8a243ddffb3575dc24c",
  creater: "0xbc98fff44b9de6957515c809d5a17e311987444a",
  description: "A simple DID impletation"
}
Contract.create(c_2)

# init app

app = %{
  name: "SoulCard",
  description: "Web3 Name Card focus on Buidlers",
  encrypted_secret_key: "12345678",
  chain_tags: ["venachain"],
  contract_id_list: [c, c_2],
  url: "https://soulcard.noncegeek.com"
}

SuperIssuer.App.create(app)

# %{id: id} = Chain.create(%{
#   adapter: "FiscoBcos"
#   name: "WeLight",
#   config: %{
#     "webase" => "http://127.0.0.1:5002",
#     "weid" => "http://127.0.0.1:6001"
#   }
# })

# evidence_fac_abi =
#   File.read!("contract/evidence/evidence_fac.abi")

# erc20_abi =
#   File.read!("contract/erc20/erc20.abi")

# erc721_abi =
#   File.read!("contract/erc721/erc721.abi")
# alias SuperIssuer.ContractTemplate

# %{id: evi_id} =
#   ContractTemplate.create(%{
#   name: "EvidenceFactory",
#   abi: evidence_fac_abi
# })

# %{id: erc20_id} =
#   ContractTemplate.create(%{
#   name: "ERC20",
#   abi: erc20_abi
# })

# %{id: erc_721_id} =
#   ContractTemplate.create(%{
#   name: "ERC721",
#   abi: erc721_abi
# })

# alias SuperIssuer.Contract
# Contract.create(%{
#   chain_id: id,
#   contract_template_id: evi_id,
#   address: "TODO",
#   init_params: %{
#     "evidenceSigners" => ["0xbf1731dc34c4c6f9cb034b9386931318f365bda3",
#      "0x0ca04d68d490fffbac15e38b018904f8222239ae"]
#   },
#   description: "柏链存证合约",
#   creater: "TODO"
# })
# Contract.create(%{
#   chain_id: id,
#   contract_template_id: erc20_id,
#   address: "TODO",
#   init_params: %{
#     "decimals" => 0,
#     "governance" => "TODO=creater",
#     "name" => "WeLightEnergy",
#     "symbol" => "VLE"
#   },
#   description: "Erc20合约_VLE",
#   creater: "TODO"
# })
# Contract.create(%{
#   chain_id: id,
#   contract_template_id: erc721_id,
#   address: "TODO",
#   init_params: %{
#     "governance" => "TODO=creater",
#     "name" => "WeLightNFT",
#     "symbol" => "VLNFT"
#   },
#   description: "Erc721合约_VLNFT",
#   creater: "TODO"
# })
