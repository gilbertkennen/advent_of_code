defmodule Day01 do
  @moduledoc """
  Today we are counting open and close parentheses.

  It is very common in Elixir code to create 'pipelines' where the result of one function is 'piped' into the first element of the next function with the |> operator.

  Both parts of today's challenge share the need to count parentheses, but use them in a different way. In the private function floor_stream/1, we use Stream.scan to emit the new floor number after each character. Streams are lazy, so when part_two/1 finds a basement floor, calculation stops.

  """

  @doc """
  Given a string of open and closed parentheses, calculates their 'sum' with '(' being +1 and ')' being -1.

  ## Examples

      iex> Day01.part_one("(())")
      0

      iex> Day01.part_one("()()")
      0

      iex> Day01.part_one("(((")
      3

      iex> Day01.part_one("(()(()(")
      3

      iex> Day01.part_one("))(((((")
      3

      iex> Day01.part_one("())")
      -1

      iex> Day01.part_one("))(")
      -1

      iex> Day01.part_one(")))")
      -3

      iex> Day01.part_one(")())())")
      -3
  """
  @spec part_one(String.t) :: integer
  def part_one(parens_string) do
    parens_string
    |> floor_stream
    |> Enum.reduce(0, fn n, _ -> n end)
  end


  @doc """
  Given a string of open and closed parentheses and sums as in `Day01.part_one/1`, provides the 1-based index of the first negative sum.

  ## Examples

      iex> Day01.part_two(")")
      1

      iex> Day01.part_two("()())")
      5
  """
  @spec part_two(String.t) :: integer
  def part_two(parens_string) do
    parens_string
    |> floor_stream
    |> Enum.find_index(&(&1 < 0))
    |> Kernel.+(1)
  end


  @spec floor_stream(String.t) :: Enumerable.t
  defp floor_stream(parens_string) do
    parens_string
    |> String.graphemes
    |> Stream.scan(0, fn
         "(", acc -> acc + 1
         ")", acc -> acc - 1
       end)
  end

end
