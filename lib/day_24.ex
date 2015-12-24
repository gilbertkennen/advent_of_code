defmodule Day24 do
  def pack(filename, compartments) do
    packages =
      filename
      |> parse_file

    compartment_weight = packages |> Enum.sum |> div(compartments)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.find_value(fn n ->
      first_compartment(packages, n, compartment_weight)
      |> Enum.sort_by(&quantum/1)
      |> Enum.find(&balanceable?(packages -- &1,
                                 compartments - 1,
                                 compartment_weight))
    end)
    |> quantum
  end


  def quantum(list), do: Enum.reduce(list, 1, &(&1 * &2))


  def first_compartment(packages, n, compartment_weight) do
    uniq_iterations(packages, n)
    |> Enum.filter(&(Enum.sum(&1) == compartment_weight))
  end


  def uniq_iterations(list, length, acc \\ [])
  def uniq_iterations(_, 0, acc), do: [acc]
  def uniq_iterations([], _, _), do: []
  def uniq_iterations([h|t], length, acc) do
    uniq_iterations(t, length - 1, [h | acc]) ++
    uniq_iterations(t, length, acc)
  end


  def balanceable?(list, 2, compartment_weight) do
    [h | t] = list |> Enum.sort_by(&(-&1))
    balanceable?(t, compartment_weight - h, [h], &(&1.() != [] || &2.() != []))
  end
  def balanceable?(list, compartments, compartment_weight) when compartments > 2 do
    [h | t] = list |> Enum.sort_by(&(-&1))

    balanceable?(t, compartment_weight - h, [h], &(&1.() ++ &2.()))
    |> Enum.any?(&balanceable?(t -- &1, compartments - 1, compartment_weight))
  end


  def balanceable?(_, 0, acc, _), do: [acc]
  def balanceable?([], _, _, _), do: []
  def balanceable?(_, n, _, _) when n < 0, do: []
  def balanceable?([h | t], compartment_weight, acc, fun) do
    new_weight = compartment_weight - h
    new_t = Enum.filter(t, &(&1 <= new_weight))

    fun.(
      fn -> balanceable?(new_t, new_weight, [h | acc], fun) end,
      fn -> balanceable?(t, compartment_weight, acc, fun) end
    )
  end


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      line
      |> String.rstrip
      |> Integer.parse
      |> elem(0)
    end)
  end
end
