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
    page_contents = template_index(Mix.env)
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
