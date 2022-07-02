defmodule OrdSetTest do
  use ExUnit.Case
  doctest OrdSet

  test "has the same functions as MapSet" do
    mapset_functions =
      MapSet.__info__(:functions)
      |> Keyword.delete(:__struct__)
      |> OrdSet.new()

    ordset_functions = OrdSet.__info__(:functions) |> OrdSet.new()

    assert OrdSet.subset?(mapset_functions, ordset_functions)
  end
end
