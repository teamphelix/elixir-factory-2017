defmodule Twytter.TweetProdConsumer do
  require Db.Tweet
  use GenStage

  def init(arg) do
    {:producer_consumer, :ok}
  end

  defp get_record(tweet) do
    db_tweet = Db.Tweet.first_or_create(tweet)
    db_tweet = Db.Tweet.update_votes(db_tweet, tweet.favorite_count)
  end

  def handle_events(tweets, _from,  _state) do
     processed_tweets = tweets |> Enum.map(&get_record/1)

    {:noreply, processed_tweets, :ok}
  end
end
