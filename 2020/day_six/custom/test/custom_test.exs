defmodule CustomTest do
  use ExUnit.Case
  doctest Custom

  test "greets the world" do
    assert Custom.hello() == :world
  end
end
