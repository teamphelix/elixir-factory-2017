defmodule Web.Router do
  require EEx
  use Plug.Router
  use Plug.Builder

  plug Plug.Logger
  plug :match
  plug :dispatch

  plug Plug.Static, 
    at: "/", 
    from: {:web, "priv/static"},
    only: ~w(css js)

  @index_template Application.app_dir(:web, "priv/views/index.html.eex")

  EEx.function_from_file :defp, :template_index, @index_template, [:env]

  get "/" do
    # page_contents = EEx.eval_file(@index_template, [env: Mix.env])
    page_contents = template_index(Mix.env)
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
    # send_file(
    #   conn, 
    #   200, 
    #   Application.app_dir(:web, "priv/static/index.html.eex"))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  # def start_link do
  #    Plug.Adapters.Cowboy.http(EventsServer.Router, [])
  # end
end
