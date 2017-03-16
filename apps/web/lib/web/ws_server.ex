defmodule Web.WsServer do
  use GenServer

  def start_link(topic, opts \\ []) do
    GenServer.start_link(__MODULE__, topic, opts)
  end

  def subscribe(topic \\ "message") do
    Registry.register(:ws_registry, topic, :socket)
  end

  def broadcast(data, topic \\ "message") do
    {:ok, msg} = Poison.encode(data)
    Registry.dispatch(:ws_registry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, msg)
    end)
  end

  def messages_received(pid) do
    GenServer.call(pid, :messages_received)
  end

  def init(topic) do
    Registry.start_link(:duplicate,topic,[])
    {:ok, []}
  end

  def handle_info({:message, msg}, state) do
    {:noreply, [msg|state]}
  end

  def handle_info({:text, msg}, state) do
    {:noreply, state}
  end

  def handle_call(:messages_received, _from, state) do
    {:reply, Enum.reverse(state), state}
  end

end
