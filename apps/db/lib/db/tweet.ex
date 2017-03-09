defmodule Db.Tweet do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "tweets" do
    field :tweet_id, :integer, unique: true
    field :question, :string
    field :name, :string
    field :favorite_count, :integer

    timestamps
  end
end
