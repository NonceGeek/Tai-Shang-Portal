defmodule SuperIssuerWeb.CredentialController do
  use SuperIssuerWeb, :controller

  @explorer_prefix "https://weimang.cyberemd.com/explorer/#/transaction/transactionDetail?pkHash="
  def index(conn, params) do
    credential =
    %{cptId: cptId}=
      conn
      |> get_session(:credential)
      |> StructTranslater.to_atom_struct()
      |> credential_handler()

    render(
      clean_session(conn),
      "#{cptId}.html",
      %{
        credential: credential
      })
  end

  def credential_handler(
    %{
      cptId: 1,
      claim: claim
      } = credential) do
    repre_handled
        = StructTranslater.str_to_atom_map(claim.representative)
    evidence_value_handled
        = StructTranslater.str_to_atom_map(claim.evidence_info.value)
    IO.puts inspect claim.evidence_info
    evidence_handled =
      claim.evidence_info
      |> Map.put(:value, evidence_value_handled)
      |> Map.put(:tx_link, @explorer_prefix <> claim.evidence_info.tx_id)
    claim =
      claim
      |> Map.put(:representative, repre_handled)
      |> Map.put(:evidence_info, evidence_handled)
    %{credential | claim: claim}
  end

  def clean_session(conn) do
    conn
    |> fetch_session()
    # |> delete_session(:credential)
  end
end
