defmodule WebTest do
  use ExUnit.Case
  use Plug.Test

  alias Web.Router
  doctest Web

  @opts Router.init([])

  test "returns 200 at /" do
    conn = conn(:get, "/", "")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end
end
