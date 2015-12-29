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


  def flip(:on), do: :off
  def flip(:off), do: :on


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


  # This algorithm can put negative regions into the existing area, but they
  # shouldn't count, so delete them when we see them.
  def combine_lum(l, {val_r, coords_r}) when val_r <= 0 do
    {[l], [coords_r], []}
  end

  # When we add a negative region, we should look for something to reduce.
  # This is intentionally a bit more generic than it needs to be in order to
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


  def sum_part_two(regions) do
    Enum.reduce(regions, 0, fn
      {val, _}, acc when val <= 0 -> acc
      {val, _} = region, acc ->
        acc + size(region) * val
    end)
  end


  def add_region(region, regions, combine_fun) do
    add_region([region], regions, [], combine_fun)
  end


  def add_region(new, [], acc, _), do: :lists.reverse(new, acc)
  def add_region(new, [region | regions], acc, combine_fun) do
    {new, intersections, existing} =
      Enum.reduce(new, {[], [], []}, fn n_reg, n_acc ->
        combine_fun.(n_reg, region)
        |> combine_accumulators(n_acc)
      end)

    acc =
      subtract_multi(region, intersections)
      |> :lists.reverse(existing)
      |> :lists.reverse(acc)

    add_region(new, regions, acc, combine_fun)
  end


  def combine_accumulators({l_acc1, l_acc2, l_acc3}, {r_acc1, r_acc2, r_acc3}) do
    {
      :lists.reverse(l_acc1, r_acc1),
      :lists.reverse(l_acc2, r_acc2),
      :lists.reverse(l_acc3, r_acc3)
    }
  end


  def size({_, {x..xx, y..yy}}), do: ((xx - x + 1) * (yy - y + 1))


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


defmodule Day06_2 do

  defmodule Row do

    def start_link(length, init) do
      Agent.start_link(fn ->
        (1..length)
        |> Enum.map(fn _ -> init end)
      end)
    end


    def stop(row) do
      Agent.stop(row)
    end


    def apply_action_to_cols(row, action_fun, cols) do
      Agent.cast(row, fn vals ->
        {head, mid, tail} = split_3(vals, cols)
        mid = Enum.map(mid, action_fun)
        combine(head, mid, tail)
      end)
    end


    def sum(row) do
      Agent.get(row, &Enum.sum/1)
    end


    def combine(head, mid, tail) do
      :lists.reverse(head, :lists.reverse(mid, tail))
    end


    def split_3(vals, l..r) do
      {head, rest} = split(vals, l)
      {mid, tail} = split(rest, r - l + 1)
      {head, mid, tail}
    end


    def split(vals, n) do
      split(vals, n, [])
    end


    def split(vals, 0, acc), do: {acc, vals}

    def split([], _, acc), do: {acc, []}

    def split([h | t], n, acc), do: split(t, n - 1, [h | acc])

  end


  def part_one(filename) do
    filename
    |> parse_file
    |> run_lights(&part_one_action/1)
  end


  def part_one_action(:toggle), do: &abs(&1 - 1)

  def part_one_action(:off), do: fn _ -> 0 end

  def part_one_action(:on), do: fn _ -> 1 end


  def part_two(filename) do
    filename
    |> parse_file
    |> run_lights(&part_two_action/1)
  end


  def part_two_action(:off) do
    fn
      n when n <= 1 -> 0
      n -> n - 1
    end
  end

  def part_two_action(:on), do: fn n -> n + 1 end

  def part_two_action(:toggle), do: fn n -> n + 2 end


  def run_lights(actions, act_fun) do
    row_processes = generate_rows(1000, 1000, 0)

    actions
    |> apply_actions_to_row_processes(row_processes, act_fun)

    light_count = row_processes |> count_lights

    Enum.each(row_processes, &Row.stop/1)

    light_count
  end


  def generate_rows(count, length, init) do
    (1..count)
    |> Enum.map(fn _ -> {:ok, row} = Row.start_link(length, init); row end)
  end


  def stop_rows(rows) do
    Enum.each(rows, &Row.stop/1)
  end


  def apply_actions_to_row_processes(actions, row_processes, act_fun) do
    actions
    |> Enum.each(fn {action, {cols, rows}} ->
      apply_action_to_cols_in_rows(row_processes, rows,
                                   act_fun.(action), cols)
      end)
  end

  def apply_action_to_cols_in_rows(row_processes, rows, action_fun, cols) do
    row_processes
    |> Enum.slice(rows)
    |> Enum.each(&Row.apply_action_to_cols(&1, action_fun, cols))
  end


  def count_lights(row_processes) do
    row_processes
    |> Enum.map(&Row.sum/1)
    |> Enum.sum
  end


  def parse_file(filename) do
    import String, only: [to_integer: 1]
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      [_, action, from_x, from_y, to_x, to_y] =
        Regex.run(~r/(toggle|on|off) (\d+),(\d+) through (\d+),(\d+)/, line)

      {String.to_atom(action),
       {(to_integer(from_x) - 1)..(to_integer(to_x) - 1),
        (to_integer(from_y) - 1)..(to_integer(to_y) - 1)}
      }
    end)
  end
end

defmodule Day06_3 do
  use Bitwise

  def part_one(filename) do
    filename
    |> parse_file
    |> run_lights(&part_one_action/3)
  end


  def part_one_action(:off, [row], bitmask) do
    [
      row
      |> Bitwise.bxor(bitmask)
      |> Bitwise.band(row)
    ]
  end

  def part_one_action(:on, [row], bitmask) do
    [
      row
      |> Bitwise.bor(bitmask)
    ]
  end

  def part_one_action(:toggle, [row], bitmask) do
    [
      row
      |> Bitwise.bxor(bitmask)
    ]
  end


  def part_two(filename) do
    filename
    |> parse_file
    |> run_lights(&part_two_action/3)
  end


  def part_two_action(:on, row, bitmap) do
    increment(row, bitmap)
  end

  def part_two_action(:toggle, [h | t], bitmap) do
    [h | increment(t, bitmap)]
  end

  def part_two_action(:off, row, bitmap) do
    deincrement(row, Enum.reduce(row, &Bitwise.bor/2) |> Bitwise.band(bitmap) )
  end


  def increment(rem, 0), do: rem

  def increment([], bitmap), do: [bitmap]

  def increment([h | t], bitmap) do
    [Bitwise.bxor(h, bitmap) | increment(t, Bitwise.band(h, bitmap))]
  end


  def deincrement(rem, 0), do: rem

  def deincrement([h | t], bitmap) do
    new_t =
      case deincrement(t, h |> Bitwise.bxor(bitmap) |> Bitwise.band(bitmap)) do
        [0] -> []
        result -> result
      end

    [Bitwise.bxor(h, bitmap) | new_t]
  end


  def run_lights(actions, act_fun) do
    actions
    |> Enum.reduce(generate_grid(1000, 1000, [0]), fn {action, {rows, cols}}, grid ->
      bitmask = make_bitmask(cols)
      {head, mid, tail} = split_3(grid, rows)
      mid = Enum.map(mid, fn row ->
        act_fun.(action, row, bitmask)
      end)
      combine(head, mid, tail)
    end)
    |> Enum.map(&multi_popcount/1)
    |> Enum.sum
  end



  def multi_popcount(list) do
    list
    |> Enum.reduce({0, 1}, fn n, {acc, mult} ->
      {acc + popcount(n) * mult, mult * 2}
    end)
    |> elem(0)
  end


  def popcount(n) do
    for(<< bit::1 <- :binary.encode_unsigned(n) >>, do: bit)
    |> Enum.sum
  end


  def generate_grid(rows, _, init) do
    (1..rows)
    |> Enum.map(fn _ -> init end)
  end


  def make_bitmask(from..to) do
    1
    |> Bitwise.bsl(to - from + 1)
    |> Kernel.-(1)
    |> Bitwise.bsl(from)
  end


  def combine(head, mid, tail) do
    :lists.reverse(head, :lists.reverse(mid, tail))
  end


  def split_3(vals, l..r) do
    {head, rest} = split(vals, l)
    {mid, tail} = split(rest, r - l + 1)
    {head, mid, tail}
  end


  def split(vals, n) do
    split(vals, n, [])
  end


  def split(vals, 0, acc), do: {acc, vals}

  def split([], _, acc), do: {acc, []}

  def split([h | t], n, acc), do: split(t, n - 1, [h | acc])


  def parse_file(filename) do
    import String, only: [to_integer: 1]
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      [_, action, from_x, from_y, to_x, to_y] =
        Regex.run(~r/(toggle|on|off) (\d+),(\d+) through (\d+),(\d+)/, line)

      {String.to_atom(action),
       {(to_integer(from_x) - 1)..(to_integer(to_x) - 1),
       (to_integer(from_y) - 1)..(to_integer(to_y) - 1)}
      }
    end)
  end

end
