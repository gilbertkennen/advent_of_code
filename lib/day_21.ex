defmodule Day21 do
  defmodule Fighter do
    defstruct [:hp, {:damage, 0}, {:armor, 0}, {:gold_spent, 0}]
  end

  defmodule Shop do
    defstruct weapons: [], armor: [], rings: []
  end

  defmodule Item do
    defstruct [:cost, {:damage, 0}, {:armor, 0}]
  end


  def part_one(player, boss, shop_fn) do
    shop = parse_shop(shop_fn)

    possible_players(player, shop)
    |> Enum.filter(fn p ->
      turns_to_kill(p, boss) <= turns_to_kill(boss, p)
    end)
    |> Enum.min_by(&(&1.gold_spent))
  end

  def part_two(player, boss, shop_fn) do
    shop = parse_shop(shop_fn)

    possible_players(player, shop)
    |> Enum.filter(fn p ->
      turns_to_kill(p, boss) > turns_to_kill(boss, p)
    end)
    |> Enum.max_by(&(&1.gold_spent))
  end

  def add_to_player(items, player) do
    items
    |> Enum.reduce(player, fn i, p ->
      %{p |
        damage: p.damage + i.damage,
        armor: p.armor + i.armor,
        gold_spent: p.gold_spent + i.cost
       }
      end)
  end

  def turns_to_kill(%{damage: damage}, %{hp: hp, armor: armor}) do
    (hp / max(damage - armor, 1)) |> Float.ceil |> trunc
  end

  def possible_players(player, shop) do
    nothing = %Item{cost: 0}
    for(
      weapon <- shop.weapons,
      armor <- [nothing | shop.armor],
      ring1 <- [nothing | shop.rings],
      ring2 <- [nothing | (shop.rings -- [ring1])]
    ) do
      [weapon, armor, ring1, ring2]
    end
    |> Enum.map(&add_to_player(&1, player))
  end


  def parse_shop(filename) do
    filename
    |> File.stream!
    |> Enum.reduce({%Shop{}, nil}, fn
      "\n", {shop, _} -> {shop, nil}

      line, {shop, nil} ->
        dept =
          case Regex.run(~r/^.*:/, line) do
            ["Weapons:"] -> :weapons
            ["Armor:"] -> :armor
            ["Rings:"] -> :rings
        end
        {shop, dept}

      line, {shop, dept} ->
        [_name, cost, damage, armor] =
          line
          |> String.rstrip
          |> String.split(~r/\s\s+/)

          item = %Item{cost: String.to_integer(cost),
                       damage: String.to_integer(damage),
                       armor: String.to_integer(armor)
                      }

        {Map.update!(shop, dept, &[item | &1]), dept}
    end)
    |> elem(0)
  end
end
