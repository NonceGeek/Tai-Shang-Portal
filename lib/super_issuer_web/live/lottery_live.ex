defmodule SuperIssuerWeb.LotteryLive do
  use Phoenix.LiveView
  alias SuperIssuerWeb.{LotteryView, LotteryLive}
  alias SuperIssuer.ServiceCoupon
  alias SuperIssuerWeb.Router.Helpers, as: Routes

  def render(assigns) do
    LotteryView.render("lottery.html", assigns)
  end

  def mount(%{"coupon" => coupon_payload}, _session, socket) do
    coupon = ServiceCoupon.get_by_coupon(coupon_payload)
    {
      :ok,
      socket
      |> assign(coupon: coupon)
    }
  end
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(coupon: nil)
    }
  end

  def handle_event("submit_coupon", %{"coupon" => coupon_payload}, socket) do
    coupon = ServiceCoupon.get_by_coupon(coupon_payload)
    do_handle_event(coupon, socket)
  end

  def handle_event(
    "submit_lottery",
    payload,
    %{assigns: %{coupon: coupon}} = socket) do
    # to be used
    IO.puts inspect payload
    # {:ok, _res} = ServiceCoupon.change(coupon, %{is_used: true})
    {
      :noreply,
      socket
    }
  end

  @doc """
    way 0x01: trans params in path
    way 0x02: directly assign to socket
  """
  def do_handle_event(%{service_name: "lottery", is_used: false, coupon: coupon_payload}, socket) do


    {
      :noreply,
      socket
      |> redirect(to: Routes.live_path(socket, LotteryLive, %{coupon: coupon_payload}))
    }
  end

  def do_handle_event(_others, socket) do
    {:noreply, socket}
  end
end
