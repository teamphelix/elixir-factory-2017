defmodule DbTest do
  use ExUnit.Case
  doctest Db
  alias Db
  import Ecto.Query, only: [from: 2]

  setup do
    Db.Repo.delete_all(Db.Tweet)
    :ok
  end

  defp query_for_tweet(tweet) do
    from t in "tweets",
      where: not(is_nil(t.tweet_id)) and t.tweet_id == ^tweet.id_str,
      select: %{id: t.id}
  end

  test "creates a new question when id is new" do
    Db.Tweet
      .first_or_create(%ExTwitter.Model.Tweet{
        id_str: "test",
        text: "What do you think about Brail?",
        favorite_count: 0
      })

    found_question = Db.Repo.one query_for_tweet(%{id_str: "test"})
    assert found_question != nil
  end

  test "updates favorite_count with new favorite_count of found tweet" do
    new_question = %Db.Tweet{favorite_count: 0, tweet_id: "1234"}
    saved = Db.Repo.insert!(new_question)

    query = from t in "tweets",
            where: t.tweet_id == ^saved.tweet_id,
            select: %{votes: t.favorite_count}

    found_question = Db.Repo.one query

    question = Db.Tweet
      .first_or_create(%ExTwitter.Model.Tweet{
        id: "12345",
        id_str: "12345",
        text: "What do you think about Rails?",
        favorite_count: 0
      })

    # Find tweet & update tweet favorite_count
    updated_tweet = Db.Tweet.update_votes(question, 2)

    assert updated_tweet.favorite_count == 2
  end

end
