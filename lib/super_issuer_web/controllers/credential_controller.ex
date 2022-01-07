defmodule SuperIssuerWeb.CredentialController do
  use SuperIssuerWeb, :controller

  @credit_top_level 10
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

  @spec credential_handler(%{:claim => any, :cptId => 1 | 100_002, optional(any) => any}) :: %{
          :claim => any,
          :cptId => 1 | 100_002,
          optional(any) => any
        }
  @doc """
    100002: Lesson Study Cred.
    1: WeLight Node Cred.
  """
  def credential_handler(
    %{
      cptId: 100_002,
      claim: claim
    } =credential)  do
      %{credential | claim: claim}
  end

  def credential_handler(
    %{
      cptId: 100_003,
      claim: claim
    } =credential) do

    %{
      credential | claim:
      claim
      |> handle_credit_level()
    }
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

  def handle_credit_level(%{credit_level: credit_level} = claim) do
    credit_handled =
      "☆"
      |> String.duplicate(@credit_top_level - credit_level)
      |> Kernel.<>(String.duplicate("★", credit_level))
    Map.put(claim, :credit_level, credit_handled)
  end

  def clean_session(conn) do
    conn
    |> fetch_session()
    # |> delete_session(:credential)
  end
end
