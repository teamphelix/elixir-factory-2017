defmodule Twytter do

alias Twytter.TweetService
alias Twytter.TweetConsumer
alias Twytter.TweetProdConsumer

  def start do
    {:ok, producer} = GenStage.start_link(TweetService, "#elixabot")
    {:ok, prod_con} = GenStage.start_link(TweetProdConsumer, :ok)
    {:ok, consumer} = GenStage.start_link(TweetConsumer, :ok)

    GenStage.sync_subscribe(prod_con, to: producer, max_demand: 10)
    GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 5)
  end
end
