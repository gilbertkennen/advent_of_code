defmodule Day13 do
  def part_one(filename) do
    values = parse_file(filename)
    arrangements =
      diners(values)
      |> circular_iterations

    Enum.max_by(arrangements, &calculate(&1, values))
    |> calculate(values)
  end

  def part_two(filename) do
    values = parse_file(filename)
    arrangements =
      ["Me" | diners(values)]
      |> circular_iterations

    Enum.max_by(arrangements, &calculate(&1, values))
    |> calculate(values)
  end

  def parse_file(filename) do
    filename
    |> File.stream!
    |> Stream.map(fn line ->

      [_, subject, direction, amount, object] =
        Regex.run(~r/^(\w+) would (\w+) (\d+).* (\w+)\.$/, line)

      amount =
        case direction do
          "gain" -> amount |> Integer.parse |> elem(0)
          "lose" -> -1 * (amount |> Integer.parse |> elem(0))
        end

      {{subject, object}, amount}
    end)
    |> Enum.into(%{})
  end

  def diners(values) do
    values
    |> Map.keys
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq
  end

  def circular_iterations([a]), do: [[a]]
  def circular_iterations([a,b]), do: [[a,b]]
  def circular_iterations([fixed | items]) do
    items
    |> pairwise_iterations
    |> Enum.flat_map(fn [l, r] = lr ->
      head = [fixed, l, r]

      (items -- lr)
      |> iterations
      |> Enum.map(&(head ++ &1))
    end)
  end

  def pairwise_iterations([l, r]), do: [[l, r]]
  def pairwise_iterations([l | t]) do
    Enum.into(t, pairwise_iterations(t), &[l, &1])
  end

  def iterations([]), do: [[]]
  def iterations(list) do
    for h <- list, t <- iterations(list -- [h]), do: [h|t]
  end

  def calculate([h|_] = diners, values) do
    diners
    |> Enum.chunk(2, 1, [h])
    |> Enum.reduce(0, fn [sub, ob], acc ->
      acc + Map.get(values, {sub, ob}, 0) + Map.get(values, {ob, sub}, 0)
    end)
  end
end
