defmodule SuperIssuerWeb.TestController do
  use SuperIssuerWeb, :controller

  def index(conn, _params) do
    render(conn, "test.html")
  end
end
