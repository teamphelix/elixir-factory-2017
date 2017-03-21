defmodule Twytter.TweetService do
  use GenStage

  def init(hashtag) do
    {:producer, %{hashtag: hashtag, last_tweet: nil}}
  end

  def handle_demand(demand, %{hashtag: hashtag, last_tweet: last_tweet}) do
    opts = [count: demand]
    opts = case last_tweet do
      %ExTwitter.Model.Tweet{id_str: id} -> Keyword.put(opts, :since_id, id)
      _ -> opts
    end

    tweets = ExTwitter.search(hashtag, opts)
    last_tweet = List.last(tweets)
    {:noreply, tweets, %{last_tweet: last_tweet, hashtag: hashtag}}
  end
end
