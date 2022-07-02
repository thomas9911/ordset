# OrdSet

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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ord_set` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ord_set, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ord_set>.
