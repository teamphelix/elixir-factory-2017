defmodule SocketHandlerTest do
  use ExUnit.Case
  use Plug.Test
  doctest Web

  # alias Web.SocketHandler

  @opts Web.SocketHandler.init([], [], [])

  test "the truth" do
    assert 1 + 1 == 2
  end

  setup_all do
    {:ok, number: 2}
  end

  test "broadcast", state do
    assert 1 + 1 == state[:number]
  end

end