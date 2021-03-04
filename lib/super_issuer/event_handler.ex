defmodule SuperIssuer.EventHandler do
  alias SuperIssuer.Ethereum.EventLog
  alias SuperIssuer.Event
  alias SuperIssuer.Repo

  def handle_event_by_contract(%Event{} = event) do
    event
    |> Repo.preload(tx: :contract)
    |> do_handle_event_by_contract()
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
    abi = event_preloaded.tx.contract.abi
    obvious_event = EventLog.decode(
      abi,
      event_preloaded.topics,
      event_preloaded.data
      )

    Map.put(event_preloaded, :obvious_event, obvious_event)
  end
end
