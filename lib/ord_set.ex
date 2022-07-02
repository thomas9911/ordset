defmodule OrdSet do
  @moduledoc """
  Elixir wrapper around `:ordsets` erlang module.
  Acts like a normal `MapSet` but adds in sorted order.

  What this library does is forward the methods to the `:ordsets` module but adds some Elixir flavour.
  Like having the first argument be the set instead of the last,
  have different function names to look like `MapSet`

  OrdSet is just a list, so guards like `in/2`, `==/2` just work[^™].

  ```elixir
  iex> 4 in OrdSet.new([1,2])
  false
  iex> 1 in OrdSet.new([1,2])
  true
  iex> OrdSet.new([1,2,1,2]) == OrdSet.new([1,2])
  true
  iex> OrdSet.new([1,2,1,2]) == OrdSet.new([3])
  false
  iex> [1,2,1,2,1,1] |> OrdSet.new() |> length()
  2
  ```

  Also Enum functions just work[^™].

  ```elixir
  iex> [2,5,4,5,2,1] |> OrdSet.new() |> Enum.sort()
  OrdSet.new([1,2,4,5])
  ```

  [^™]: You should ofcourse test this yourself
  """

  @compile {:inline, put: 2, delete: 2, member?: 2, equal?: 2, filter: 2, reject: 2}

  @type t(term) :: list(term)
  @type t :: list

  @doc """
  ```elixir
  iex> init = fn
  ...>   set when OrdSet.is_empty(set) -> OrdSet.new([1])
  ...>   set -> set
  ...> end
  iex> OrdSet.new() |> init.()
  OrdSet.new([1])
  iex> [3,6] |> OrdSet.new() |> init.()
  OrdSet.new([3,6])
  ```
  """
  @spec is_empty(t()) :: boolean
  defguard is_empty(set) when set == []

  @doc """
  Creates a empty `OrdSet`
  """
  @spec new() :: OrdSet.t()
  defdelegate new(), to: :ordsets

  @doc """
  Creates a new `OrdSet` from `Enumerable.t()`

  ```elixir
  iex> OrdSet.new(0..5)
  OrdSet.new([0,1,2,3,4,5])
  iex> OrdSet.new(5..0//-1)
  OrdSet.new([0,1,2,3,4,5])
  ```
  """
  @spec new(Enumerable.t()) :: OrdSet.t()
  def new(list) when is_list(list), do: :ordsets.from_list(list)

  def new(enumerable) do
    enumerable
    |> Enum.to_list()
    |> new()
  end

  @doc """
  Creates a new `OrdSet` from `Enumerable.t()` with given function

  ```elixir
  iex> OrdSet.new([0,1,2,3,4,5], &rem(&1, 3))
  OrdSet.new([0,1,2])
  ```
  """
  @spec new(Enumerable.t(), (term -> term)) :: OrdSet.t()
  def new(enumerable, func) do
    enumerable
    |> Enum.map(func)
    |> new()
  end

  @doc """
  Puts the item to the end of the set

  ```elixir
  iex> [1,2,3,4] |> OrdSet.new() |> OrdSet.put(5)
  OrdSet.new([1,2,3,4,5])
  iex> [1,2,3,4] |> OrdSet.new() |> OrdSet.put(3)
  OrdSet.new([1,2,3,4])
  iex> [1,2,4] |> OrdSet.new() |> OrdSet.put(3)
  OrdSet.new([1,2,3,4])
  ```
  """
  @spec put(t(), term) :: t()
  def put(set, item) do
    :ordsets.add_element(item, set)
  end

  @doc """
  Deletes the item from the set
  ```elixir
  iex> [1,2,4,3] |> OrdSet.new() |> OrdSet.delete(2)
  OrdSet.new([1,4,3])
  ```
  """
  @spec delete(t(), term) :: t()
  def delete(set, item) do
    :ordsets.del_element(item, set)
  end

  @spec size(t()) :: pos_integer()
  defdelegate size(set), to: :ordsets

  @doc """
  Returns a set containing only members that set_a and set_b have in common.

  ```elixir
  iex> OrdSet.intersection(OrdSet.new(1..4), OrdSet.new(3..6))
  [3, 4]
  ```
  """
  @spec intersection(t(), t()) :: t()
  defdelegate intersection(set_a, set_b), to: :ordsets

  @doc """
  Returns a set that is set_a without the members of set_b

  ```elixir
  iex> OrdSet.difference(OrdSet.new(1..4), OrdSet.new(3..6))
  [1, 2]
  ```
  """
  @spec difference(t(), t()) :: t()
  defdelegate difference(set_a, set_b), to: :ordsets, as: :subtract

  @doc """
  Returns a set containing all members of set_a and set_b.

  ```elixir
  iex> OrdSet.union(OrdSet.new(1..4), OrdSet.new(3..6))
  [1,2,3,4,5,6]
  iex> OrdSet.new(1..2) |> OrdSet.union(OrdSet.new(5..6)) |> OrdSet.union(OrdSet.new(1..3))
  [1,2,3,5,6]
  ```
  """
  @spec union(t(), t()) :: t()
  defdelegate union(set_a, set_b), to: :ordsets

  @doc """
  iex> 2 in OrdSet.new(1..3)
  true
  iex> 1..3 |> OrdSet.new() |> OrdSet.member?(2)
  true
  iex> 1..3 |> OrdSet.new() |> OrdSet.member?(8)
  false
  """
  @spec member?(t(), term) :: boolean
  def member?(set, item) do
    :ordsets.is_element(item, set)
  end

  @doc """
  iex> OrdSet.equal?(OrdSet.new(1..3), OrdSet.new(1..3))
  true
  iex> OrdSet.equal?(OrdSet.new(1..4), OrdSet.new(1..3))
  false
  iex> OrdSet.equal?(OrdSet.new([1,2,3]), OrdSet.new([3,2,1]))
  true
  """
  @spec member?(t(), t()) :: boolean
  def equal?(set_a, set_b) do
    set_a == set_b
  end

  @doc """
  Checks if set_a's members are all contained in set_b.

  ```elixir
  iex> OrdSet.disjoint?(OrdSet.new([1, 2, 3]), OrdSet.new([4, 5, 6]))
  true
  iex> OrdSet.disjoint?(OrdSet.new([4, 5, 6]), OrdSet.new([2, 3, 4]))
  false
  ```
  """
  @spec disjoint?(t(), t()) :: boolean
  defdelegate disjoint?(set_a, set_b), to: :ordsets, as: :is_disjoint

  @doc """
  Checks if set_a's members are all contained in set_b.

  ```elixir
  iex> MapSet.subset?(MapSet.new([4]), MapSet.new([4, 5, 6]))
  true
  iex> OrdSet.subset?(OrdSet.new([4]), OrdSet.new([4, 5, 6]))
  true
  iex> MapSet.subset?(MapSet.new([4, 5, 6]), MapSet.new([4]))
  false
  iex> OrdSet.subset?(OrdSet.new([4, 5, 6]), OrdSet.new([4]))
  false
  ```
  """
  @spec subset?(t(), t()) :: boolean
  defdelegate subset?(set_a, set_b), to: :ordsets, as: :is_subset

  @doc """
  Converts `OrdSet` to a list.

  Ps: I don't think this does anything because a `OrdSet` is already a list
  """
  @spec to_list(t()) :: list
  defdelegate to_list(set), to: :ordsets

  @doc """
  Filters the set by returning only the elements from `set` for which invoking `fun` returns a truthy value.

  ```elixir
  iex> MapSet.filter(MapSet.new(1..5), fn x -> x > 3 end)
  MapSet.new([4, 5])
  ```
  """
  @spec filter(t(), (term -> as_boolean(term))) :: t()
  def filter(set, func) do
    :ordsets.filter(func, set)
  end

  @doc """
  Returns a set by excluding the elements from `set` for which invoking `fun` returns a truthy value.

  ```
  iex> OrdSet.reject(OrdSet.new(1..5), fn x -> rem(x, 2) != 0 end)
  OrdSet.new([2, 4])
  ```
  """
  @spec reject(t(), (term -> as_boolean(term))) :: t()
  def reject(set, func) do
    :ordsets.filter(&(!func.(&1)), set)
  end

  @doc """
  Get the largest element in the set

  ```elixir
  iex> 0..5 |> OrdSet.new() |> OrdSet.max()
  5
  ```
  """
  @spec max(t()) :: term
  defdelegate max(set), to: List, as: :last

  @doc """
  Get the smallest element in the set

  ```elixir
  iex> 0..5 |> OrdSet.new() |> OrdSet.min()
  0
  ```
  """
  @spec min(t()) :: term
  defdelegate min(set), to: List, as: :first
end
