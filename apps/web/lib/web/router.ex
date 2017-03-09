defmodule Web.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, "Yay Elixir!")
  end

  # def start_link do
  #    Plug.Adapters.Cowboy.http(EventsServer.Router, [])
  # end
end
