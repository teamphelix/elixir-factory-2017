defmodule Db.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add :tweet_id, :integer, unique: true
      add :question, :string
      add :name, :string
      add :favorite_count, :integer

      timestamps
    end
  end
end
