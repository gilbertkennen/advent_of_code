defmodule Day03 do
  @moduledoc """
  Today we are keeping track of movement on a grid and eliminating duplicates.

  We finally get a fairly straightforward use of pattern matching in `Day03.move/2` which produces different output depending on the move direction.

  `Day03.part_two` uses a recursion technique to keep track of both "Santas" by swapping their positions in a tuple.

  Otherwise, it is fairly straightforward: Take the input, turn it into an Enumerable, use Stream.scan as a combination reduce and map, count the unique results.
  """

  @type coords :: {integer, integer}

  @doc """
  Count the unique houses visited based on moves on an infinite grid. The starting space counts as 1 even if it is never re-visited.

  ## Examples

      iex> Day03.part_one(">")
      2

      iex> Day03.part_one("^>v<")
      4

      iex> Day03.part_one("^v^v^v^v^v")
      2
  """
  @spec part_one(String.t) :: integer
  def part_one(path_string) do
    path_string
    |> String.graphemes
    |> Stream.scan({0,0}, &move/2)
    |> count
  end


  @doc """
  Count the unique houses visited based on moves sent alternately to two "Santas". The starting space counts as 1 even if it is never re-visited.

  ## Examples

      iex> Day03.part_two("^v")
      3

      iex> Day03.part_two("^>v<")
      3

      iex> Day03.part_two("^v^v^v^v^v")
      11
  """
  @spec part_two(String.t) :: integer
  def part_two(path_string) do
    path_string
    |> String.graphemes
    |> Stream.scan({{0,0}, {0,0}}, fn
         dir, {curr, other} -> {other, move(dir, curr)}
       end)
    |> Stream.map(&elem(&1, 1))
    |> count
  end


  @spec move(String.t, coords) :: coords
  defp move("^", {x, y}), do: {x, y+1}

  defp move("v", {x, y}), do: {x, y-1}

  defp move(">", {x, y}), do: {x+1, y}

  defp move("<", {x, y}), do: {x-1, y}


  @spec count([coords]) :: integer
  defp count(visits) do
    visits
    |> Enum.into([{0,0}])
    |> Enum.uniq
    |> Enum.count
  end

end
