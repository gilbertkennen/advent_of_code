defmodule Day09 do
  defp parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.flat_map(fn string ->
      [_, node1, node2, cost] = Regex.run(~r/^(.+) to (.+) = (\d+)$/, string)
      {cost, _} = Integer.parse(cost)
      [{node1, {node2, cost}}, {node2, {node1, cost}}]
    end)
    |> Enum.reduce(%{}, fn {key1, {key2, val}}, map ->
      Map.update(map, key1,
                 Map.put_new(%{}, key2, val),
                 &Map.put_new(&1, key2, val))
    end)
  end

  defp routes(edge_map) do
    nodes = Map.keys(edge_map)
    perm(nodes)
  end

  def perm([_] = l), do: [l]
  def perm(list) do
    for h <- list, t <- perm(list -- [h]), do: [h|t]
  end

  defp route_cost(route, edge_map) do
    route
    |> Enum.chunk(2, 1)
    |> Enum.reduce(0, fn [s, d], acc ->
      acc + edge_map[s][d]
    end)
  end

  def part_one(filename) do
    edge_map = parse_file(filename)

    edge_map
    |> routes
    |> Enum.map(&route_cost(&1, edge_map))
    |> Enum.min
  end

  def part_two(filename) do
    edge_map = parse_file(filename)

    edge_map
    |> routes
    |> Enum.map(&route_cost(&1, edge_map))
    |> Enum.max
  end
end
