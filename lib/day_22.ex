defmodule Day22.Spell do
  defstruct [:id, {:cost, 0}, {:duration, 1}, {:damage, 0}, {:heal, 0}, {:armor, 0}, {:mana, 0}]
end


defmodule Day22.Fighter do
  defstruct [:hp, {:damage, 0}, {:armor, 0}]
end


defmodule Day22.Mage do
  defstruct [:hp, {:mana, 0}, {:armor, 0}]
end


defmodule Day22 do
  alias Day22.Spell

  @spells [
    %Spell{id: "Poison", cost: 173, duration: 6, damage: 3},
    %Spell{id: "Magic Missile", cost: 53, damage: 4},
    %Spell{id: "Drain", cost: 73, damage: 2, heal: 2},
    %Spell{id: "Shield", cost: 113, duration: 6, armor: 7},
    %Spell{id: "Recharge", cost: 229, duration: 5, mana: 101}
  ]

  def battle(mage, boss, hp_loss \\ 0, spells \\ @spells) do
    mage_turn(mage, boss, spells, [], hp_loss, 0, nil)
  end

  def mage_turn(mage, boss, spells, effects, hp_loss, mana_used, max_mana) do
    mage = %{mage | hp: mage.hp - hp_loss}
    castable = castable_spells(mage, spells, effects, mana_used, max_mana)

    case check_finished(mage, boss, mana_used, max_mana, castable) do
      false ->
        castable
        |> Enum.reduce(max_mana, fn spell, max_m ->
          mage = %{mage | mana: mage.mana - spell.cost}
          mana_used = mana_used + spell.cost
          {mage, boss, effects} = apply_effects(mage, boss, [spell | effects])
          boss_turn(mage, boss, spells, effects, hp_loss, mana_used, max_m)
        end)
      result -> result
    end
  end


  def boss_turn(mage, boss, spells, effects, hp_loss, mana_used, max_mana) do
    case check_finished(mage, boss, mana_used, max_mana) do
      false ->
        mage = attack(boss, mage)
        {mage, boss, effects} = apply_effects(mage, boss, effects)
        mage_turn(mage, boss, spells, effects, hp_loss, mana_used, max_mana)
      result -> result
    end
  end


  def attack(fighter, opponent) do
    %{opponent |
      hp: opponent.hp - max(1, fighter.damage - opponent.armor)
     }
  end


  def check_finished(mage, boss, mana_used, max_mana, castable \\ nil) do
    cond do
      castable == [] or mage.hp <= 0 -> max_mana
      boss.hp <= 0 -> mana_used
      true -> false
    end
  end


  def castable_spells(mage, spells, effects, _, nil) do
    spells
    |> Enum.filter(fn s ->
      s.cost <= mage.mana &&
      !Enum.any?(effects, &(&1.id == s.id))
    end)
  end
  def castable_spells(mage, spells, effects, mana_used, max_mana) do
    castable_spells(mage, spells, effects, mana_used, nil)
    |> Enum.filter(&(&1.cost + mana_used < max_mana))
  end


  def apply_effects(mage, boss, effects) do
    mage = %{mage | armor: 0}

    effects
    |> Enum.reduce({mage, boss, []}, &apply_effect(&1, &2))
  end


  def apply_effect(%{duration: 1} = e, {mage, boss, acc}) do
    heal = if mage.hp <= 0, do: 0, else: e.heal
    {
      %{mage |
        hp: mage.hp + heal,
        mana: mage.mana + e.mana,
        armor: mage.armor + e.armor
       },
      %{boss |
        hp: boss.hp - e.damage
       },
      acc
    }
  end
  def apply_effect(e, acc) do
    {mage, boss, acc} = apply_effect(%{e | duration: 1}, acc)
    {mage, boss, [%{e | duration: e.duration - 1} | acc]}
  end
end
