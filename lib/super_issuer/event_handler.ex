defmodule SuperIssuer.EventHandler do
  alias SuperIssuer.Ethereum.EventLog
  alias SuperIssuer.Event
  alias SuperIssuer.Repo

  def handle_event_by_contract(%Event{} = event) do
    event
    |> Repo.preload(tx: :contract)
    |> do_handle_event_by_contract()
  end

  def do_handle_event_by_contract(event_preloaded) do

  end
end
