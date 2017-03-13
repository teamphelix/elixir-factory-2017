defmodule Twytter.TweetService do
  use GenStage

  def init(arg) do
    {:producer, arg}
  end

  defp to_record(tweet) do
    %{
      text: tweet.text,
    }
  end

  def handle_demand(demand, state) do
    tweets = ExTwitter.search(state, [count: demand]) |> Enum.map(&to_record/1)
    {:noreply, tweets, state}
  end
end
