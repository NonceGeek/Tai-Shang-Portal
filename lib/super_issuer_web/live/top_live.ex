defmodule SuperIssuerWeb.TopLive do

  use Phoenix.LiveView
  alias SuperIssuerWeb.TopView
  alias SuperIssuer.{Contract, Evidence, EvidenceHandler, Credential}
  alias SuperIssuer.Repo


  def render(assigns) do
    TopView.render("top.html", assigns)
  end

  def mount(_params, _session, socket) do

    credentials =
      Credential.get_all()
      |> Enum.map(fn c ->
        Credential.preload(c)
      end)

    {:ok,
      socket
      |> assign(credentials: credentials)
    }
  end
end
