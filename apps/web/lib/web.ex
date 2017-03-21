defmodule Web do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Registry, [:duplicate, :ws_registry]),
      Plug.Adapters.Cowboy.child_spec(
        :http, Web.Router, [], [
          port: 4001,
          dispatch: dispatch()
        ])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Logger.info "Starting web"
    Supervisor.start_link(children, opts)
  end

  def run do
    # {:ok, _} = Plug.Adapters.Cowboy.http Web.Router, []
  end

  defp dispatch do
    [
      {:_, [
        {"/ws", Web.SocketHandler, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Web.Router, []}}
      ]}
    ]
  end
end
