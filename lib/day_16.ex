defmodule Day16 do
  def find_aunts(aunts_fn, facts_fn, gt_list \\ [], lt_list \\ []) do
    facts = facts_fn |> parse_facts
    aunts = aunts_fn |> parse_aunts

    Enum.filter(aunts, fn {_, items} ->
      Enum.all?(items, fn {key, val} ->
        cond do
          key in gt_list -> facts[key] < val
          key in lt_list -> facts[key] > val
          true -> facts[key] == val
        end
      end)
    end)
  end


  def parse_aunts(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      [_, number, info] = Regex.run(~r/^Sue (\d+): (.*)$/, line)

      items =
        info
        |> String.split(", ")
        |> parse_items
      {String.to_integer(number), items}
    end)
  end


  def parse_facts(filename) do
    filename
    |> File.stream!
    |> parse_items
  end


  def parse_items(item_list) do
    item_list
    |> Enum.map(fn item ->
      [name, amount] = item |> String.rstrip |> String.split(": ")
      {name, String.to_integer(amount)}
    end)
  end

end
