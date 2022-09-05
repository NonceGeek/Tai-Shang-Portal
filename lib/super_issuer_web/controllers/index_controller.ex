defmodule SuperIssuerWeb.IndexController do
  use SuperIssuerWeb, :controller
  alias SuperIssuer.CredentialVerifier
  alias SuperIssuer.WeidInteractor
  alias SuperIssuer.Chain
  alias SuperIssuer.{Account, App, Block}

  @payload %{
    name: "微芒·星辰区块链产业人才培养计划",
    slogan: "",
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

    chain = Chain.get_default_chain()
    {_result, msg} = WeidInteractor.verify_credential_pojo(chain, credential)

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
    render(conn, "index.html",
        payload: create_payload()
    )
  end

  def handle_msg(true), do: "证书合法！"

  def handle_msg(other), do: "验证失败！原因：#{other}"

  def get_data() do

  end
  def create_payload() do
    changeset = Ecto.Changeset.change(%CredentialVerifier{})

    acct_num = Account.count()
    app_num = App.count()
    block_best_height = Block.get_newest().block_height

    payload = %{@payload | changeset: changeset}
    payload
    |> Map.put(:acct_num, acct_num)
    |> Map.put(:app_num, app_num)
    |> Map.put(:block_best_height, block_best_height)
  end


end
