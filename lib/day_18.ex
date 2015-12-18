defmodule Day18 do

  def part_one(filename, steps) do
    board = filename |> parse_file

    (1..steps)
    |> Enum.reduce(board, fn _, b -> step(b) end)
    |> board_sum
  end


  def part_two(filename, steps) do
    board = filename |> parse_file

    (1..steps)
    |> Enum.reduce(board, fn _, b ->
      b
      |> turn_on_corners
      |> step
    end)
    |> turn_on_corners
    |> board_sum
  end


  def turn_on_corners(board) do
    [{0, 0}, {0, -1}, {-1, 0}, {-1, -1}]
    |> Enum.reduce(board, fn {r, c}, b ->
      List.update_at(b, r, fn row ->
        List.update_at(row, c, fn _ -> 1 end)
      end)
    end)
  end


  def step(board) do
    len = board |> hd |> length
    row_pad = (1..len) |> Enum.map(fn _ -> [0,0,0] end)

    board
    |> Enum.map(&adjacents(&1, 0))
    |> adjacents(row_pad)
    |> Enum.map(fn line ->
      line
      |> zip_3
      |> Enum.map(&node_step/1)
    end)
  end


  def adjacents(list, padding) do
    [padding | list]
    |> Enum.chunk(3, 1, [padding])
  end



  def zip_3([a, b, c]), do: :lists.zip3(a, b, c)


  def node_step({l_list, [l_elem, this, r_elem], r_list}) do
    adj = sum(l_list) + l_elem + r_elem + sum(r_list)

    case {this, adj} do
      {0, 3} -> 1
      {1, n} when n in [2, 3] -> 1
      _ -> 0
    end
  end


  def sum(list), do: Enum.reduce(list, 0, &Kernel.+/2)


  def board_sum(board) do
    board
    |> Enum.map(&sum/1)
    |> sum
  end


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      line
      |> String.rstrip
      |> to_char_list
      |> Enum.map(fn
        ?. -> 0
        ?# -> 1
      end)
    end)
  end
end
