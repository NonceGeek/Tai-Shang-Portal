defmodule SuperIssuerWeb.IndexController do
  use SuperIssuerWeb, :controller
  alias SuperIssuer.CredentialVerifier, as: CredentialVerifier
  alias SuperIssuer.WeidAdapter, as: WeidAdapter

  @payload %{
    name: "微芒·星辰区块链产业人才培养计划",
    slogan: "分布式 | 无边界 | 未来学院",
    credetialverifier: %CredentialVerifier{},
    changeset: nil,
    verify_result: nil
  }

  @doc """
    post action
  """

  def index(
        conn,
        %{"btn_clicked" => "verify",
          "credential_verifier" => %{
            # "pubkey" => pubkey,
            "file" => %Plug.Upload{
              filename: _f_name,
              path: path
            }
          }
        }
      ) do
    credential =
      path
      |> File.read!()
      |> Poison.decode!()

    {_result, msg} = WeidAdapter.verify_credential_pojo(credential)

    conn
    |> put_flash(:info, handle_msg(msg))
    |> render("index.html", payload: create_payload())
  end

  def index(conn, %{"btn_clicked" => "read",
  "credential_verifier" => %{
    # "pubkey" => pubkey,
    "file" => %Plug.Upload{
      filename: _f_name,
      path: path
    }
  }}) do
    credential =
      path
      |> File.read!()
      |> Poison.decode!()
    conn
    |> put_session(:credential, credential)
    |> redirect(to: Routes.credential_path(conn, :index))
  end

  def index(conn, %{"login_out" => "yes"}) do
    conn
    |> clear_session()
    |> redirect(to: Routes.index_path(conn, :index))
  end

  def index(conn, _params) do

    render(conn, "index.html", payload: create_payload())
  end

  def handle_msg(true), do: "证书合法！"

  def handle_msg(other), do: "验证失败！原因：#{other}"

  def create_payload() do
    changeset = Ecto.Changeset.change(%CredentialVerifier{})
    %{@payload | changeset: changeset}
  end


end
