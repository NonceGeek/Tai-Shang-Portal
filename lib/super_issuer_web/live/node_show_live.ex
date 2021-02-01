defmodule SuperIssuerWeb.NodeShowLive do
  use Phoenix.LiveView
  alias SuperIssuerWeb.Router.Helpers, as: Routes

  alias SuperIssuer.School

  @tick 100
  @width 100
  @rotation %{left: 180, right: 0, up: -90, down: 90}

  @board [
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0),
    ~w(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
  ]

  @image_path "/images/"
  @raw_nodes [
    %{x_index: 2,y_index: 3},
    %{x_index: 4,y_index: 4},
    %{x_index: 6,y_index: 2},
    %{x_index: 8,y_index: 5},
    %{x_index: 10,y_index: 4},
    %{x_index: 12,y_index: 2},
  ]
  @board_rows length(@board)
  @board_cols length(hd(@board))

  def render(assigns) do
    ~L"""
    <form phx-change="update_settings">
      <select name="tick" onchange="this.blur()">
        <option value="50" <%= if @tick == 50, do: "selected" %>>50</option>
        <option value="100" <%= if @tick == 100, do: "selected" %>>100</option>
        <option value="200" <%= if @tick == 200, do: "selected" %>>200</option>
        <option value="500" <%= if @tick == 500, do: "selected" %>>500</option>
      </select>
      <input type="range" min="50" max="100" name="width" value="<%= @width %>" onmouseup="blur()"/>
      <%= @width %>px
    </form>
    <div class = "game-title">
      <br><center><h1>节点浏览器 · 可视化版</h1><center>
    </div>
    <div class="game-container">

      <div
          style="
                 width: <%= @width %>px;
                 height: <%= @width %>px;
      ">

      </div>
      <%= for {_, block} <- @blocks do %>
            <div class="block <%= block.type %>"
            style="left: <%= block.x %>px;
                    top: <%= block.y %>px;
                    width: <%= block.width %>px;
                    height: <%= block.width %>px;
        "></div>
        <% end %>

      <%= for node <- @nodes do %>
        <image phx-click="show_node_info" phx-value-key="<%= node.school_id%>"src="<%= Routes.static_path(@socket, "/images/"<>node.image_path) %>" class="node"
        style="left: <%= node.x %>px;
        top: <%= node.y %>px;
        ">
        </a>
      <% end %>

      <image src="<%= Routes.static_path(@socket, "/images/welight.png") %>" class="node"
      style="left: 600px;
      top: 600px;
      ">
      </a>
    </div>
    <div class="pannel" >
      <br>
      <center><h3>节点信息 / Node Informations</h3></center>
      <b>学校名称：</b><%= @school.school_name %>
      <br><br>
      <b>节点ID：</b><%= @school.node_id %>
      <br><br>
      <b>学校主页：</b><%= @school.url %>
    </div>
    """
  end

  def get_school_with_coord(width) do
    School.get_all()
    |> Enum.with_index()
    |> Enum.map(fn {school, index} ->
      school
      |> Map.put(:x, Enum.at(@raw_nodes, index).x_index * width)
      |> Map.put(:y, Enum.at(@raw_nodes, index).y_index * width)
    end)
  end
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(%{
        heading: :stationary,
        width: @width,
        tick: @tick,
        rotation: 0,
        row: 1,
        col: 1,
        x: nil,
        y: nil
      })
      |> build_board()
      |> build_nodes()
      |> advance()
      |> init_school()

    {:ok, socket}
    # if connected?(socket) do
    #   {:ok, schedule_tick(socket)}
    # else
    #   {:ok, socket}
    # end
  end

  # def handle_info(:tick, socket) do
  #   new_socket =
  #     socket
  #     |> game_loop()
  #     |> schedule_tick()

  #   {:noreply, new_socket}
  # end

  def init_school(socket) do
    school = School.get_by_school_id("BFU")
    socket
    |> assign(:school, school)
  end

  def handle_event("update_settings", %{"width" => width, "tick" => tick}, socket) do
    {width, ""} = Integer.parse(width)
    {tick, ""} = Integer.parse(tick)

    new_socket =
      socket
      |> assign(width: width)
      # |> update_tick(tick)
      |> build_board()
      |> build_nodes()

    {:noreply, new_socket}
  end

  def handle_event("show_node_info", %{"key"=> key}, socket) do
    school = School.get_by_school_id(key)

    {:noreply,
      socket
      |> assign(:school, school)
    }
  end

  # def handle_event("keydown", payload, socket) do
  #   {:noreply, turn(socket, payload["key"])}
  # end

  # defp update_tick(socket, tick) when tick >= 50 and tick <= 1000 do
  #   assign(socket, :tick, tick)
  # end

  # defp turn(socket, "ArrowLeft"), do: go(socket, :left)
  # defp turn(socket, "ArrowDown"), do: go(socket, :down)
  # defp turn(socket, "ArrowUp"), do: go(socket, :up)
  # defp turn(socket, "ArrowRight") do
  #   go(socket, :right)
  # end
  # defp turn(socket, _), do: socket

  # defp go(%{assigns: %{heading: heading}} = socket, heading), do: socket

  # defp go(socket, heading) do
  #   socket
  #   |> assign(rotation: Map.fetch!(@rotation, heading))
  #   |> assign(heading: heading)
  # end

  def game_loop(socket) do
    socket
    |> advance()
  end

  # defp schedule_tick(socket) do
  #   Process.send_after(self(), :tick, socket.assigns.tick)
  #   socket
  # end

  def build_nodes(socket) do
    nodes =
      socket.assigns.width
      |> get_school_with_coord()

    assign(socket, :nodes, nodes)
  end

  defp build_board(socket) do
    width = socket.assigns.width

    {_, blocks} =
      Enum.reduce(@board, {0, %{}}, fn row, {y_index, acc} ->
        {_, blocks} =
          Enum.reduce(row, {0, acc}, fn

            "0", {x_index, acc} ->
              {x_index + 1,
               Map.put(acc, {y_index, x_index}, %{
                 type: :empty,
                 x: x_index * width,
                 y: y_index * width,
                 width: width
               })}

          end)

        {y_index + 1, blocks}
      end)

    assign(socket, :blocks, blocks)
  end

  defp advance(socket) do
    %{width: width, heading: heading, blocks: blocks} = socket.assigns
    col_before = socket.assigns.col
    row_before = socket.assigns.row
    maybe_row = row(row_before, heading)
    maybe_col = col(col_before, heading)

    {row, col} =
      case block(maybe_row, maybe_col, blocks) do
        :wall -> {row_before, col_before}
        :empty -> {maybe_row, maybe_col}
      end

    socket
    |> assign(:row, row)
    |> assign(:col, col)
    |> assign(:x, col * width)
    |> assign(:y, row * width)
  end

  defp col(val, :left) when val - 1 >= 1, do: val - 1
  defp col(val, :right) when val + 1 < @board_cols - 1, do: val + 1
  defp col(val, _), do: val

  defp row(val, :up) when val - 1 >= 1, do: val - 1
  defp row(val, :down) when val + 1 < @board_rows - 1, do: val + 1
  defp row(val, _), do: val

  def block(row, col, blocks) do
    Map.fetch!(blocks, {row, col}).type
  end
end
