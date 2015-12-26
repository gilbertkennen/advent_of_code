defmodule Day25 do
  import Bitwise, only: [bsr: 2]
  import Integer, only: [is_odd: 1]

  def find_code(row, col) do
    mod_pow(252533, find_code_number(row, col) - 1, 33554393, 20151125)
  end


  def find_code_number(row, col) do
    div((row + col - 1) * (row + col), 2) - row + 1
  end


  def mod_pow(base, exp, mod, acc \\ 1)

  def mod_pow(_, _, 1, _), do: 0

  def mod_pow(base, exp, mod, acc) do
    do_mod_pow(rem(base, mod), exp, mod, acc)
  end


  def do_mod_pow(_, 0, _, acc), do: acc

  def do_mod_pow(base, exp, mod, acc) when is_odd(exp) do
    do_mod_pow(base, exp - 1, mod, rem(acc * base, mod))
  end

  def do_mod_pow(base, exp, mod, acc) do
    do_mod_pow(rem(base * base, mod), bsr(exp, 1), mod, acc)
  end
end
