defmodule Db.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Db.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Db.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
