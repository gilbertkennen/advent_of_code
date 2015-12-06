defmodule SantaLights do

  def execute(filename) do
    filename
    |> parse_file
    |> Enum.reduce([], fn
      {:toggle, reg}, on_regions -> toggle(reg, on_regions)
    {:on, reg}, on_regions -> on(reg, on_regions)
      {:off, reg}, on_regions -> off(reg, on_regions)
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
  def off(reg, on_regions) do
    on_regions
    |> Enum.flat_map(&subtract(&1, reg))
  end


  # Subtract reg from all and place it in the output.
  def on(reg, on_regions) do
    [reg | off(reg, on_regions)]
  end


  # Manually subtract reg from all existing regions, saving the
  # intersections and then subtract those from the toggle intersection
  # and keep whatever is left.
  def toggle(reg, on_regions) do
    {new_grid, overlaps} =
      Enum.reduce(on_regions, {[], []}, fn old, {acc, overlaps} ->
        if intersection = two_dim_intersection(reg, old) do
          old_mask = negative(old, intersection)
          {old_mask ++ acc, [intersection | overlaps]}
        else
          {[old | acc], overlaps}
        end
      end)

    Enum.reduce(overlaps, [reg], &off/2) ++ new_grid
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


  def block({x_range, y_range}) do
    for x <- x_range, y <- y_range, do: {x, y}
  end


  def on(map, coords) do
    Map.update(map, coords, 1, &(&1 + 1))
  end

  def off(map, coords) do
    Map.update(map, coords, 0, fn
      n when n <= 1 -> 0
      n -> n - 1
    end)
  end

  def toggle(map, coords) do
    Map.update(map, coords, 2, &(&1 + 2))
  end

  def do_stuff({action, ranges}, map) do
    block(ranges)
    |> Enum.reduce(map, fn coords, map ->
      IO.inspect action
      case action do
        :on -> on(map, coords)
        :off -> off(map, coords)
        :toggle -> toggle(map, coords)
      end
    end)
  end

  def sum(map) do
    map
    |> Enum.reduce(0, fn
      {_, val}, acc -> acc + val
    end)
  end

  def execute(filename) do
    filename
    |> parse_file
    |> Enum.reduce(%{}, &do_stuff/2)
    |> sum
  end

end
