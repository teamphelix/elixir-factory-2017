defmodule Db.Repo.Migrations.ChangeTweetIdToString do
  use Ecto.Migration

  def change do
    alter table(:tweets)do
      modify :tweet_id, :string
    end
  end
end
