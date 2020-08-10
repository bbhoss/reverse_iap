defmodule ReverseIapTest do
  use ExUnit.Case
  doctest ReverseIap

  test "greets the world" do
    assert ReverseIap.hello() == :world
  end
end
