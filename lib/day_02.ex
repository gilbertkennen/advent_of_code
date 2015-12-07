defmodule Day02 do
  @moduledoc """
  Today, we parse strings from a file and calculate optimal solutions.

  The parse_file/1 private function is interesting here as it shows a nice pipeline.

  Otherwise, there isn't much going on in this challenge.
  """

  @type dimensions :: [integer, ...]

  @doc """
  Sums the paper dimensions from a file.
  """
  @spec part_one(String.t) :: integer
  def part_one(filename) do
    filename
    |> parse_file
    |> Enum.reduce(0, &(paper_area(&1) + &2))
  end


  @doc """
  Calculates the surface area of a box plus extra for the area of the smallest face.

  ## Examples

      iex> Day02.paper_area([2, 3, 4])
      58

      iex> Day02.paper_area([1, 1, 10])
      43
  """
  @spec paper_area(dimensions) :: integer
  def paper_area(dimensions) do
    [a, b, c] = Enum.sort(dimensions)
    3*a*b + 2*a*c + 2*b*c
  end


  @doc """
  Sums the ribbon dimensions from a file.
  """
  @spec part_two(String.t) :: integer
  def part_two(filename) do
    filename
    |> parse_file
    |> Enum.reduce(0, &(ribbon_length(&1) + &2))
  end


  @doc """
  Calculates the perimeter of the smallest face of a box and adds its volume.

  ## Examples

      iex> Day02.ribbon_length([2, 3, 4])
      34

      iex> Day02.ribbon_length([1, 1, 10])
      14
  """
  @spec ribbon_length(dimensions) :: integer
  def ribbon_length(dimensions) do
    [a, b, c] = Enum.sort(dimensions)
    2*a + 2*b + a*b*c
  end


  @spec parse_file(String.t) :: Enumerable.t
  defp parse_file(filename) do
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      line
      |> String.rstrip
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)
    end)
  end

end
