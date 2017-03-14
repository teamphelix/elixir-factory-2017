defmodule Twytter.TweetService do
  use GenStage

  def init(hashtag) do
    {:producer, %{hashtag: hashtag, last_tweet: nil}}
  end

  defp get_hashtags(%{hashtags: arr}) when length(arr) > 0 do
    Enum.map(arr, fn(x) -> x.text end)
  end

  defp get_hashtags(_other), do: nil

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
