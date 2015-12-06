defmodule SantaLights do

  def execute(filename) do
    filename
    |> parse_file
    |> Enum.reduce([], fn
      {action, reg}, on_regions -> act(action, reg, on_regions)
    end)
    |> sum
  end


  def parse_file(filename) do
    import String, only: [to_integer: 1]
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      [_, action, from_x, from_y, to_x, to_y] =
        Regex.run(~r/(toggle|on|off) (\d+),(\d+) through (\d+),(\d+)/, line)

      {String.to_atom(action),
       {to_integer(from_x)..to_integer(to_x),
       to_integer(from_y)..to_integer(to_y)}
      }
    end)
  end


  def sum(on_regions) do
    Enum.reduce(on_regions, 0, fn
      {x..xx, y..yy}, acc -> acc + ((xx - x + 1) * (yy - y + 1))
    end)
  end


  # Subtract reg from all existing regions.
  def act(:off, reg, on_regions) do
    on_regions
    |> Enum.flat_map(&subtract(&1, reg))
  end


  # Subtract reg from all and place it in the output.
  def act(:on, reg, on_regions) do
    [reg | act(:off, reg, on_regions)]
  end


  # Manually subtract reg from all existing regions, saving the
  # intersections and then subtract those from the toggle intersection
  # and keep whatever is left.
  def act(:toggle, reg, on_regions) do
    {new_grid, overlaps} =
      Enum.reduce(on_regions, {[], []}, fn old, {acc, overlaps} ->
        if intersection = two_dim_intersection(reg, old) do
          old_mask = negative(old, intersection)
          {old_mask ++ acc, [intersection | overlaps]}
        else
          {[old | acc], overlaps}
        end
      end)

    Enum.reduce(overlaps, [reg], &act(:off, &1, &2)) ++ new_grid
  end


  # Given two arbitrary regions, subtract the second from the first.
  def subtract(l, r) do
    if intersection = two_dim_intersection(l, r) do
      negative(l, intersection)
    else
      [l]
    end
  end


  # Removes a mask from the first region. Automatically generates four
  # possible new regions in an I shape and filters invalid ones.
  # This requires that the second region be fully contained within the first.
  defp negative({lx..lxx, ly..lyy}, {rx..rxx, ry..ryy}) do
    [{lx..lxx, ly..(ry-1)},
     {lx..lxx, (ryy+1)..lyy},
     {lx..(rx-1), ry..ryy},
     {(rxx+1)..lxx, ry..ryy}]

    |> Enum.filter(fn {x..xx, y..yy} -> x <= xx and y <= yy end)
  end


  # If both dimensions have a valid intersection, then there is a 2d intersection
  defp two_dim_intersection({lx, ly}, {rx, ry}) do
    case {one_dim_intersection(lx, rx), one_dim_intersection(ly, ry)} do
      {x, y} when x == nil or y == nil -> nil
      reg -> reg
    end
  end


  defp one_dim_intersection(l..ll, r..rr) do
    if l < r, do: min = r, else: min = l
    if ll < rr, do: max = ll, else: max = rr
    if min <= max, do: min..max, else: nil
  end

end

defmodule VariableLights do
  import SantaLights, only: [parse_file: 1]


  def execute(filename) do
    table = init()

    filename
    |> parse_file
    |> Enum.each(fn {action, ranges} ->
      ranges
      |> block
      |> Enum.each(&act(action, table, &1))
    end)

    result = sum(table)
    cleanup(table)
    result
  end


  def block({x_range, y_range}) do
    for x <- x_range, y <- y_range, do: {x, y}
  end


  def act(:on, table, coords) do
    inc(table, coords, 1)
  end

  def act(:toggle, table, coords) do
    inc(table, coords, 2)
  end

  def act(:off, table, coords) do
    dec(table, coords, -1)
  end


  def init do
    :ets.new(__MODULE__, [:set])
  end


  def cleanup(table) do
    :ets.delete(table)
  end


  def inc(table, coords, amount) do
    :ets.update_counter(table, coords, amount, {coords, 0})
  end


  def dec(table, coords, amount) do
    :ets.update_counter(table, coords, {2, amount, 0, 0}, {coords, 0})
  end


  def sum(table) do
    :ets.foldl(fn {_, n}, acc -> acc + n end, 0, table)
  end

end
