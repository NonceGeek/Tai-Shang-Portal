defmodule SuperIssuerWeb.UserController do
  use SuperIssuerWeb, :controller
  alias SuperIssuer.{User, WeidAdapter}

  def new(conn, _params) do
    changeset = User.change_user(%User{})
    render(conn, "sign_up.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    {:ok, weid} = WeidAdapter.create_weid()
    user_params_with_weid =
      user_params
      |> Map.put("weid", weid)
    case User.create_user(user_params_with_weid) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.index_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "sign_up.html", changeset: changeset)
    end
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
