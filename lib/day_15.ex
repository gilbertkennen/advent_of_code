defmodule Day15 do

  def part_one(filename, amount) do
    filename
    |> parse_file
    |> optimize(amount, &part_one_total/1)
  end


  def part_one_total(total) do
    [:capacity, :durability, :flavor, :texture]
    |> Enum.reduce(1, fn quality, acc ->
      lower_bound(total[quality]) * acc
    end)
  end


  def part_two(filename, amount, calories) do
    filename
    |> parse_file
    |> optimize(amount, &part_two_total(&1, calories))
  end


  def part_two_total(%{calories: calories} = total, calories) do
    part_one_total(total)
  end
  def part_two_total(_, _), do: 0


  def optimize(ingredients, amount, fun) do
    optimize(ingredients, amount, fun, [])
    |> Enum.max
  end


  def optimize([i], amount, fun, acc) do
    [
      [multiply(i, amount) | acc]
      |> Enum.reduce(&Map.merge(&1, &2, fn _, l, r -> l + r end))
      |> fun.()
    ]
  end

  def optimize([i | t], amount, fun, acc) do
    (1..amount)
    |> Enum.flat_map(&optimize(t, amount - &1, fun, [multiply(i, &1) | acc]))
  end


  def lower_bound(int, bound \\ 0)
  def lower_bound(int, bound) when int < bound, do: bound
  def lower_bound(int, _), do: int


  def multiply(ingredient, amount) do
    Map.keys(ingredient)
    |> Enum.reduce(ingredient, fn key, ing ->
      Map.update!(ing, key, &(&1 * amount))
    end)
  end


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      [_name, capacity, durability, flavor, texture, calories] =
        line |> String.split(~r/[:,] \w+ /)

      %{
        capacity: int(capacity),
        durability: int(durability),
        flavor: int(flavor),
        texture: int(texture),
        calories: int(calories)
      }
    end)
  end


  def int(str), do: str |> Integer.parse |> elem(0)
end
