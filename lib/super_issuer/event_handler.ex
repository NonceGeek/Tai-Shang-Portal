defmodule SuperIssuer.EventHandler do
  alias SuperIssuer.Ethereum.EventLog
  alias SuperIssuer.Event
  alias SuperIssuer.Repo

  def handle_event_by_contract(%Event{} = event) do
    event
    |> Repo.preload(tx: [contract: :contract_template])
    |> do_handle_event_by_contract()
  end

  def handle_event(event, contract) do
    abi = contract.contract_template.abi
    %{signature: signature, args: args} = event_decoded = EventLog.decode(
      abi,
      event.topics,
      event.data
      )
    %{event: signature, params: args}
  end

  @doc """
    event_log exp:
    %SuperIssuer.Ethereum.EventLog{
      args: %{
        "addr" => "0x38d3e8318c86511f89e546796e1bb2fb346d6bae",
        "evi" => "1234"
      },
      event: %SuperIssuer.Ethereum.Event{
        args: [
          %SuperIssuer.Ethereum.Argument{indexed: false, name: "evi", type: :string},
          %SuperIssuer.Ethereum.Argument{
            indexed: false,
            name: "addr",
            type: :address
          }
        ],
        name: "newSignaturesEvent"
      }
    }
  """
  def do_handle_event_by_contract(event_preloaded) do
    abi = event_preloaded.tx.contract.contract_template.abi
    event_decoded = EventLog.decode(
      abi,
      event_preloaded.topics,
      event_preloaded.data
      )

    Map.put(event_preloaded, :event_decoded, event_decoded)
  end
end
