defmodule Day10 do
  def part_one(string, n \\ 40) do
    (1..n)
    |> Enum.reduce(string, fn _, acc -> look_and_say(acc) end)
    |> String.length
  end

  def part_two(string) do
    part_one(string, 50)
  end


  def look_and_say(string) do
    string
    |> String.graphemes
    |> Enum.chunk_by(&(&1))
    |> Enum.map(fn [c|_] = l ->
      (Enum.count(l) |> Integer.to_string) <> c
    end)
    |> Enum.join
  end
end
