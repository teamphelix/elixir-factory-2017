defmodule Web.WsServer do

  def broadcast(data) do
    
    {:ok, msg} = Poison.encode(data)
    broadcast ws_server, { :message, data }
  end

  defp broadcast(nil, _), do: :wtf
  defp broadcast(pid, msg) do
    send pid, msg
  end

  def start_link do
    # dispatch = :cowboy_router.compile([
    #   {:_, [
    #     {'/ws', Web.SocketHandler, []},
    #     {:_, Web.Router, []}
    #   ]}
    # ])
    # :cowboy.start_http :ws_listener, 100, [
    #   {:port, 4001}
    # ], [
    #   {:env, [{:dispatch, dispatch}]}
    # ]
  end

  def stop(_), do: :ok

  defp ws_server do
    Process.whereis(:ws_handler)
  end
end
