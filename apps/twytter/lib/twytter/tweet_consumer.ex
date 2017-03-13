defmodule Twytter.TweetConsumer do
  require Web.WsServer

  use GenStage
  def init(arg) do
    {:consumer, :ok}
  end

  def handle_events(tweets, _from, _state) do
    Web.WsServer.broadcast(tweets)
    {:noreply, [], _state}
  end
end
