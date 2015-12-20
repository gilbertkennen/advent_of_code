defmodule Day20 do
  def part_one(presents) do
    find_house(presents, 10)
  end


  def part_two(presents) do
    find_house(presents, 11, &( div(&1, &2) <= 50 ))
  end


  def find_house(presents, value, filter \\ fn _house, _elf -> true end) do
    Stream.iterate( 1, &(&1 + 1) )
    |> Enum.find( fn house ->
      house
      |> divisors
      |> Enum.filter(&filter.(house, &1))
      |> Enum.sum
      |> Kernel.*(value)
      |> Kernel.>=(presents)
    end)
  end


  def divisors(n) do
    e = n |> :math.sqrt |> trunc

    (1..e)
    |> Enum.flat_map(fn
      x when rem(n, x) != 0 -> []
      x when x != div(n, x) -> [x, div(n, x)]
      x -> [x]
    end)
  end
end
