defmodule Db.Tweet do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  import Ecto.Query, only: [from: 2]

  schema "tweets" do
    field :tweet_id, :string, unique: true
    field :question, :string
    # field :user_id, :integer
    field :favorite_count, :integer

    timestamps
  end

  def first_or_create(tweet) do
    query = from t in Db.Tweet,
            where: t.tweet_id == ^tweet.id_str,
            select: t
            
    create_tweet({Db.Repo.one(query), tweet})
  end

  defp create_tweet({ nil, tweet }) do
    new_tweet = %Db.Tweet{
      tweet_id: tweet.id_str,
      question: tweet.text,
      favorite_count: tweet.favorite_count
    }

    {:ok, saved_tweet} = Db.Repo.insert(new_tweet)
    saved_tweet
  end

  defp create_tweet({ instance, _ }), do: instance


  def update_votes(tweet, new_vote_count \\ 0) do
    case tweet.favorite_count == new_vote_count do
      true -> tweet
      false ->
        {:ok, ret} = Db.Repo.update(Db.Tweet.update_vote_changeset(tweet, %{favorite_count: new_vote_count}))
        ret
    end
  end

  def changeset(tweet, params \\ %{}) do
    tweet
      |> cast(params, [:id, :favorite_count, :text])
  end

  def update_vote_changeset(tweet, params \\ %{}) do
    tweet
      |> cast(params, [:favorite_count])
  end
end
