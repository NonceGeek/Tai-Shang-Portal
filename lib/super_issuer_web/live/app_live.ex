defmodule SuperIssuerWeb.AppLive do
  use Phoenix.LiveView
  alias SuperIssuerWeb.AppView
  alias SuperIssuer.App

  def render(assigns) do
    AppView.render("application.html", assigns)
  end

  def mount(_params, _session, socket) do
    apps =
      App.get_all()
    {:ok,
      socket
      |> assign(apps: apps)
    }
  end
end
