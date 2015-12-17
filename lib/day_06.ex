defmodule Day06 do

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
    {new_grid, intersections} =
      Enum.reduce(on_regions, {[], []}, fn old, {acc, intersections} ->
        if intersection = two_dim_intersection(reg, old) do
          old_mask = negative(old, intersection)
          {old_mask ++ acc, [intersection | intersections]}
        else
          {[old | acc], intersections}
        end
      end)

    Enum.reduce(intersections, [reg], &act(:off, &1, &2)) ++ new_grid
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
  def negative({lx..lxx, ly..lyy}, {rx..rxx, ry..ryy}) do
    [{lx..lxx, ly..(ry-1)},
     {lx..lxx, (ryy+1)..lyy},
     {lx..(rx-1), ry..ryy},
     {(rxx+1)..lxx, ry..ryy}]

    |> Enum.filter(fn {x..xx, y..yy} -> x <= xx and y <= yy end)
  end


  # If both dimensions have a valid intersection, then there is a 2d intersection
  def two_dim_intersection({lx, ly}, {rx, ry}) do
    case {one_dim_intersection(lx, rx), one_dim_intersection(ly, ry)} do
      {x, y} when x == nil or y == nil -> nil
      reg -> reg
    end
  end


  def one_dim_intersection(l..ll, r..rr) do
    min = if l < r, do: r, else: l
    max = if ll < rr, do: ll, else: rr
    if min <= max, do: min..max, else: nil
  end

end

defmodule Day06_2 do
  import Day06, only: [parse_file: 1,
                             two_dim_intersection: 2,
                             negative: 2,
                             subtract: 2]


  def execute(filename) do
    filename
    |> parse_file
    |> Enum.reduce([], fn
      {action, reg}, on_regions -> act(action, reg, on_regions)
    end)
    |> sum
  end

  def sum(regions) do
    regions
    |> Enum.reduce(0, fn {{x..xx, y..yy}, val}, acc ->
      acc + ((xx - x + 1) * (yy - y + 1) * val)
    end)
  end

  def act(:on, reg, regions) do
    do_stuff({reg, 1}, regions)
  end

  def act(:toggle, reg, regions) do
    do_stuff({reg, 2}, regions)
  end

  def act(:off, reg, regions) do
    do_stuff({reg, -1}, regions)
  end

  def do_stuff({reg, val}, regions) do
    {new_regions, intersections} =
      Enum.reduce(regions, {[], []}, fn
        {o_reg, o_val}, {new_regions, intersections}->
          if inter = two_dim_intersection(reg, o_reg) do
            new_reg = negative(o_reg, inter) |> Enum.map(&{&1, o_val})
            if (n_val = o_val + val) > 0, do: new_reg = [{inter, n_val}| new_reg]
            {new_reg ++ new_regions , [inter | intersections]}
          else
            {[{o_reg, o_val} | new_regions], intersections}
          end
      end)

    if val > 0 do
      intersections
      |> Enum.reduce([reg], &Enum.flat_map(&2, fn r -> subtract(r, &1) end))
      |> Enum.map(&{&1, val})
      |> Kernel.++(new_regions)
    else
      new_regions
    end
  end

end

defmodule VariableLights do
  import Day06, only: [parse_file: 1]


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
