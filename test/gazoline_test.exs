defmodule GazolineTest do
  use ExUnit.Case
  doctest Gazoline

  test "greets the world" do
    assert Gazoline.hello() == :world
  end
end
