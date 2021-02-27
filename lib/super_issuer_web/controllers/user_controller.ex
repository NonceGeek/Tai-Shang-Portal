defmodule SuperIssuerWeb.UserController do
  use SuperIssuerWeb, :controller
  alias SuperIssuer.{User, WeIdentity,WeidInteractor}
  alias SuperIssuer.Chain
  alias SuperIssuer.Repo

  def new(conn, _params) do

    user_changeset =
      %User{}
      |> User.changeset()

    render(
      conn,
      "sign_up.html",
      %{
        changeset: user_changeset
      })
  end

  def create(conn, %{"user" => user_params}) do
    chain = Chain.get_default_chain()
    changeset =
      User.changeset(%User{}, user_params)

    Repo.transaction(fn ->
      case do_create(chain, user_params) do
        {:error, payload} ->
        # error handler
          Repo.rollback("reason: #{inspect(payload)}")
        payload ->
          payload
      end
    end)
    |> handle_create_result(conn, changeset)
  end

  def do_create(chain, user_params) do
    user_params_restructured =
      Map.put(user_params, "group", 0)
    with {:ok, user} <- User.create_user(user_params_restructured),
         {:ok, _info} <- weid_exist?(chain, user_params_restructured),
         {:ok, weid_params} <- restructure_params(user_params_restructured, user),
         {:ok, _weidentity} <- WeIdentity.create_weidentity(weid_params) do
        {:ok, "user_and_weid_create_finished"}
    else
      {:error, error_payload} ->
        {:error, error_payload}
    end
  end

  def weid_exist?(chain, %{"weid" => weid}) do
    if WeidInteractor.exist?(chain, weid) do
      {:ok, "exist"}
    else
      {:error, "can't find weid on chain"}
    end
  end

  def restructure_params(%{"weid" => weid}, %{id: id}) do
    {:ok, %{weid: weid, user_id: id}}
  end

  def handle_create_result({:ok, _payload}, conn, _) do
    conn
    |> put_flash(:info, "Signed up successfully.")
    |> redirect(to: Routes.index_path(conn, :index))
  end
  def handle_create_result({:error, %Ecto.Changeset{}}, conn, changeset) do
    conn
    |> put_flash(:error, "Signed up failed with dateabase problem")
    |> render("sign_up.html", changeset: changeset)
  end
  def handle_create_result({:error, others}, conn, changeset) do
    conn
    |> put_flash(:error, "Signed up failed with #{inspect(others)} problem")
    |> render("sign_up.html", changeset: changeset)
  end

  def index(conn, _) do
    user_id = get_session(conn, :current_user_id)
    if user_id do
      user =
        user_id
        |> User.get_by_user_id()

      render(conn, "user.html", %{login?: true, user: user})
    else
      redirect(conn, to: Routes.user_path(conn, :new))
    end
  end
end
