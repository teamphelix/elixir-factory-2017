defmodule Web.SocketHandler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    Web.WsServer.subscribe()
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 60000

  def websocket_init(_type, req, _opts) do
    state = %{}
    {:ok, req, state, @timeout}
  end

  def websocket_handle({:message, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  def websocket_handle({:message, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_handle({:text, message}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  def websocket_info(message, req, state) do
    {:reply, {:text, to_string(message)}, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end
