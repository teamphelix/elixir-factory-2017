defmodule Twytter.TweetProdConsumer do
  use GenStage

  def init(arg) do
    {:producer_consumer, :ok}
  end

  defp get_record(tweet) do
    IO.inspect(tweet)
    %{ }
  end

  def handle_events(tweets, _from,  _state) do
     processed_tweets = tweets |> Enum.map(&get_record/1)

    {:noreply, processed_tweets, :ok}
  end
end
