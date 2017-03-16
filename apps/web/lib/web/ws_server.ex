defmodule Web.WsServer do

  def broadcast(data) do
    IO.puts("Called broadcast in WsServer")
    {:ok, msg} = Poison.encode(data)
    broadcast ws_server(), { :text, msg }
  end

  defp broadcast(nil, _) do
    IO.puts("Broadcast called with nil pid")
    :wtf
  end
  defp broadcast(pid, msg) do
    IO.puts msg
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
