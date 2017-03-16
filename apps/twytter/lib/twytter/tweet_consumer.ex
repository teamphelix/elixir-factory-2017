defmodule Twytter.TweetConsumer do
  require Web.WsServer

  use GenStage
  def init(_arg) do
    {:consumer, %{}}
  end

  def handle_subscribe(:producer, opts, from, producers) do
    pending = opts[:max_demand] || 5
    interval = opts[:interval] || 90000

    producers = Map.put(producers, from, {pending, interval})

    producers = ask_and_schedule(producers, from)

    {:manual, producers}
  end

  def handle_cancel(_, from, producers) do
    {:noreply, [], Map.delete(producers, from)}
  end


  def to_jsonable(tweet) do
    %{id: tweet.id, votes: tweet.favorite_count, text: tweet.question}
  end
  def handle_events(events, from, producers) do
    producers = Map.update!(producers, from, fn {pending, interval} ->
      {pending + length(events), interval}
    end)

    jsonable_tweets = events |> Enum.map(&to_jsonable/1)
    Web.WsServer.broadcast(jsonable_tweets)

    {:noreply, [], producers}
  end


  def handle_info({:ask, from}, producers) do
    {:noreply, [], ask_and_schedule(producers, from)}
  end

  defp ask_and_schedule(producers, from) do
    case producers do
      %{^from => {pending, interval}} ->
        GenStage.ask(from, pending)
        Process.send_after(self(), {:ask, from}, interval)
        Map.put(producers, from, {0, interval})
      %{} ->
        producers
    end
  end
end
