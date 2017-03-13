defmodule Twytter.TweetProdConsumer do
  use GenStage

  def init(arg) do
    {:producer_consumer, :ok}
  end

  def handle_events(tweets, _from,  _state) do
    for tweet <- tweets do
      IO.puts tweet.text
    end
    {:noreply, tweets, :ok}
  end
end
