defmodule FactHttpServerTest do
  use ExUnit.Case
  doctest FactHttpServer

  test "greets the world" do
    assert FactHttpServer.hello() == :world
  end
end
