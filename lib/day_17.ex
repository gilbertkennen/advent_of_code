defmodule Day17 do
  def part_one(filename, amount) do
    filename
    |> parse_file
    |> combinations(amount)
    |> Enum.count
  end

  def part_two(filename, amount) do
    filename
    |> parse_file
    |> combinations(amount)
    |> Enum.sort_by(&Enum.count/1)
    |> Stream.chunk_by(&Enum.count/1)
    |> Enum.take(1)
    |> hd
    |> Enum.count
  end

  def combinations(containers, size) do
    combinations(containers, size, [])
  end

  def combinations(_, 0, solution), do: [solution]
  def combinations(_, size, _) when size < 0, do: []
  def combinations([], _, _), do: []
  def combinations(containers, size, acc) do
    Enum.flat_map(tails(containers), fn
      [h | t] -> combinations(t, size-h, [h | acc])
    end)
  end

  def tails([]), do: []
  def tails([_ | t] = list), do: [list | tails(t)]


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      line
      |> String.rstrip
      |> String.to_integer
    end)
  end

end
