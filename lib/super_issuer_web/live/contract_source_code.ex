defmodule SuperIssuerWeb.ContractSourceCodeLive do
    use SuperIssuerWeb, :live_view
    alias SuperIssuerWeb.ContractView
    alias SuperIssuer.{User, Contract, Chain, ContractTemplate}

    def render(assigns) do
      ContractView.render("contract_source_code.html", assigns)
    end


    def mount(%{"template_id" => id}, _session, socket) do
      contract_template =
        ContractTemplate.get_by_id(id)
      {:ok,
        socket
        # |> do_mount(user)
        |> assign(contract_template: contract_template)
      }
    end

    def handle_event(_others, payload, socket) do
      {:noreply, socket}
    end

  end
