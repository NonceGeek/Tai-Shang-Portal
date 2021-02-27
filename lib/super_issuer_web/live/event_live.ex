defmodule SuperIssuerWeb.EventLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.EventView
  alias SuperIssuer.{Event, Repo, EventHandler}

  def render(assigns) do
    EventView.render("event.html", assigns)
  end

  def mount(_params, _session, socket) do
    events =
      Event.get_all()
      |> Enum.map(fn event ->
        event
        |> Repo.preload(tx: :contract)
        |> EventHandler.handle_event_by_contract()
      end)
    {:ok,
      socket
      |> assign(events: events)
    }
  end

end
