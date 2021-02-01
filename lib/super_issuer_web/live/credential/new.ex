defmodule SuperIssuerWeb.CredentialLive.New do
  use Phoenix.LiveView
  alias SuperIssuerWeb.CredentialView
  alias SuperIssuer.Credential

  def render(assigns) do
    CredentialView.render("new.html", assigns)
  end

  def mount(_params, %{
    "current_user_id" => 1
  }, socket) do

    changeset = Credential.changeset(%Credential{})
    {:ok,
    socket
    |> assign(changeset: changeset)
  }
  end

  def mount(_params, _, socket) do
    {:ok,
    socket
    |> redirect(to: "/")
  }
  end

  def handle_event("save", %{
    "credential" => %{
    "user_id" => user_id,
    "credential" => credential
  }}, socket) do
    user_id = String.to_integer(user_id)
    credential = Poison.decode!(credential)

    cre=%{
      user_id: user_id,
      credential: credential
    }
    case Credential.create(cre) do
      {:ok, cre} ->
        {:noreply,
        socket
        |> put_flash("info", "contract created")
      }
      {:error, reason} ->
        {:noreply,
        socket
        |> put_flash("error", inspect(reason))
      }
    end
  end
  # def handle_event("save", %{"contract" => contract}, socket) do
  #   contract = StructTranslater.to_atom_struct(contract)
  #   contract =
  #     contract
  #     |> Map.put(:init_params, Poison.decode!(contract.init_params))
  #   IO.puts inspect contract
  #   case Contract.create(contract) do
  #     {:ok, contract} ->
  #       {:noreply,
  #       socket
  #       |> put_flash("info", "contract created")
  #     }
  #     {:error, reason} ->
  #       {:noreply,
  #       socket
  #       |> put_flash("error", inspect(reason))
  #     }
  #   end
  # end
  def handle_event(sth, payload, socket) do
    IO.puts inspect payload
    {:noreply, socket}
  end
end
