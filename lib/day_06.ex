defmodule Day06 do

  def part_one(filename) do
    filename
    |> parse_file
    |> Enum.reverse
    |> Enum.reduce([], fn region, regions ->
      add_region(region, regions, &combine_bool/2)
      |> Enum.sort_by(&(-size(&1)))
    end)
    |> sum_part_one
  end


  def sum_part_one(regions) do
    Enum.reduce(regions, 0, fn
      {:off, _}, acc -> acc
      region, acc -> acc + size(region)
    end)
  end

  def part_two(filename) do
    filename
    |> parse_file
    |> Enum.map(fn
      {:on, coords}     -> {1,  coords}
      {:off, coords}    -> {-1, coords}
      {:toggle, coords} -> {2,  coords}
    end)
    |> Enum.reduce([], fn region, regions ->
      add_region(region, regions, &combine_lum/2)
      |> Enum.sort_by(&(-size(&1)))
    end)
    |> sum_part_two
  end

  def sum_part_two(regions) do
    Enum.reduce(regions, 0, fn
      {val, _}, acc when val <= 0 -> acc
      {val, _} = region, acc ->
        acc + size(region) * val
    end)
  end

  def size({_, {x..xx, y..yy}}), do: ((xx - x + 1) * (yy - y + 1))


  def add_region(region, regions, fun) do
    add_region([region], regions, [], fun)
  end

  def add_region(new, [], acc, _), do: :lists.reverse(new, acc)
  def add_region(new, [region | regions], acc, fun) do
    {new, intersections, existing} =
      Enum.reduce(new, {[], [], []}, fn n_reg, n_acc ->
        fun.(n_reg, region) |> combine_accumulators(n_acc)
      end)

    acc =
      subtract_multi(region, intersections)
      |> :lists.reverse(existing)
      |> :lists.reverse(acc)

    add_region(new, regions, acc, fun)
  end


  # Toggles nullify their intersection
  def combine_bool({:toggle, coords_l}, {:toggle, coords_r}) do
    {new_l, intersection} = subtract(coords_l, coords_r)
    {
      regions(new_l, :toggle),
      intersection,
      []
    }
  end
  # existing toggles flip the intersection, which is then done.
  def combine_bool({type, coords_l}, {:toggle, coords_r}) do
    {new_l, toggled} = subtract(coords_l, coords_r)

    {
      regions(new_l, type),
      toggled,
      :lists.reverse(regions(toggled, flip(type))),
    }
  end
  # existing non-toggles are already set.
  def combine_bool({type_l, coords_l}, {_, coords_r}) do
    {new_l, _} = subtract(coords_l, coords_r)

    {regions(new_l, type_l), [], []}
  end


  # This algorithm can put negative regions into the existing area, but they
  # shouldn't count, so delete them.
  def combine_lum(l, {val_r, coords_r}) when val_r <= 0 do
    {[l], [coords_r], []}
  end

  # When we add a negative region, we should look for something to reduce.
  # This is intentionally a bit more generic than it has to be in order to
  # handle other luminosity systems.
  def combine_lum({val_l, coords_l}, {val_r, coords_r}) when val_l < 0 do
    {new_l, intersection} = subtract(coords_l, coords_r)
    i_val = val_l + val_r
    new_l =
      if i_val < 0 do
        (regions(new_l, val_l) ++ regions(intersection, i_val))
      else
        regions(new_l, val_l)
      end

    {
      new_l,
      intersection,
      (if i_val > 0, do: regions(intersection, i_val), else: [])
    }
  end

  # If it is a positive value, just add an extra region.
  def combine_lum(l, _) do
    { [l], [], [], }
  end


  def combine_accumulators({l_acc1, l_acc2, l_acc3}, {r_acc1, r_acc2, r_acc3}) do
    {
      :lists.reverse(l_acc1, r_acc1),
      :lists.reverse(l_acc2, r_acc2),
      :lists.reverse(l_acc3, r_acc3)
    }
  end

  def flip(:on), do: :off
  def flip(:off), do: :on


  def regions(coords, value) do
    for coord <- coords, do: {value, coord}
  end

  def subtract(l, r) do
    if intersection = two_dim_intersection(l, r) do
      {negative(l, intersection), [intersection]}
    else
      {[l], []}
    end
  end

  def subtract_multi({type, coords}, intersections) do
    intersections
    |> Enum.reduce([coords], fn i, r ->
      Enum.flat_map(r, &(subtract(&1, i) |> elem(0)))
    end)
    |> regions(type)
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


end
