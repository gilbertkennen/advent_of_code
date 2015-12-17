defmodule Day07 do
  use Bitwise

  def part_one(filename, wire \\ "a", overrides \\ []) do
    parse_file(filename)
    |> populate_ets(overrides)
    |> make(wire)
  end

  def part_two(filename) do
    val = part_one(filename, "a")
    part_one(filename, "a", [{"b", {:wire, {:value, val}}}])
  end

  defp parse_file(filename) do
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      case String.split(String.rstrip(line), " ") do

        [arg, _, name] ->
            {name, {:wire, argify(arg)}}

        ["NOT", arg, _, name] ->
          {name, {"NOT", argify(arg)}}

        [l, kind, r, _, name] ->
          {name, {kind, argify(l), argify(r)}}

      end
    end)
  end

  defp argify(arg) do
    case Integer.parse(arg) do
      {val, _} -> {:value, val}
      :error -> arg
    end
  end

  defp populate_ets(gates, overrides) do
    table = :ets.new(__MODULE__, [])

    gates
    |> Enum.each(&:ets.insert_new(table, &1))

    overrides
    |> Enum.each(&:ets.insert(table, &1))

    table
  end

  defp make(_table, {:value, val}) do
    val
  end

  defp make(table, name) do
    case :ets.lookup_element(table, name, 2) do

      {:value, val} -> val

      other ->
        val = do_make(other, table)
        :ets.insert(table, {name, {:value, val}})
        val

    end
  end


  defp do_make({:wire, arg}, table) do
    make(table, arg)
  end

  defp do_make({"NOT", arg}, table) do
    make(table, arg)
    |> bnot
  end

  defp do_make({"LSHIFT", l, r}, table) do
    apply_2(&bsl/2, l, r, table)
  end

  defp do_make({"RSHIFT", l, r}, table) do
    apply_2(&bsr/2, l, r, table)
  end

  defp do_make({"AND", l, r}, table) do
    apply_2(&band/2, l, r, table)
  end

  defp do_make({"OR", l, r}, table) do
    apply_2(&bor/2, l, r, table)
  end

  defp apply_2(fun, l, r, table) do
    l = make(table, l)
    r = make(table, r)

    fun.(l, r)
  end
end
