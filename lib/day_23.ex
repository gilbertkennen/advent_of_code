defmodule Day23 do
  require Integer

  def part_one(filename) do
    filename
    |> parse_file
    |> execute(0, 0)
  end


  def part_two(filename) do
    filename
    |> parse_file
    |> execute(1, 0)
  end


  def execute(commands, a, b) do
    execute([], commands, a, b)
  end


  def execute(_, [], _, b), do: b

  def execute(l, [{"hlf", reg} | _] = r, a, b) do
    {a, b} = apply(reg, &div(&1, 2), a, b)
    step(l, r, a, b)
  end

  def execute(l, [{"tpl", reg} | _] = r, a, b) do
    {a, b} = apply(reg, &(&1 * 3), a, b)
    step(l, r, a, b)
  end

  def execute(l, [{"inc", reg} | _] = r, a, b) do
    {a, b} = apply(reg, &(&1 + 1), a, b)
    step(l, r, a, b)
  end

  def execute(l, [{"jmp", off} | _] = r, a, b) do
    jump(off, l, r, a, b)
  end

  def execute(l, [{"jie", reg, off} | _] = r, a, b) do
    cond_jump(off, reg, &Integer.is_even/1, l, r, a, b)
  end

  def execute(l, [{"jio", reg, off} | _] = r, a, b) do
    cond_jump(off, reg, &(&1 == 1), l, r, a, b)
  end


  def cond_jump(off, reg, fun, l, r, a, b) do
    if check(reg, fun, a, b) do
      jump(off, l, r, a, b)
    else
      step(l, r, a, b)
    end
  end


  def check("a", fun, a, _), do: fun.(a)
  def check("b", fun, _, b), do: fun.(b)


  def apply(reg, fun, a, b) do
    case reg do
      "a" -> {fun.(a), b}
      "b" -> {a, fun.(b)}
    end
  end


  def step(l, r, a, b), do: jump(1, l, r, a, b)


  def jump(0, l, r, a, b) do
    execute(l, r, a, b)
  end
  def jump(n, [c | l], r, a, b) when n < 0 do
    jump(n + 1, l, [c | r], a, b)
  end
  def jump(n, l, [c | r], a, b) when n > 0 do
    jump(n - 1, [c | l], r, a, b)
  end
  def jump(_, _, _, _, b), do: b


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      [cmd | args] =
        Regex.run(~r/^(.{3}) ([^\s]+)(?:, (.+))?$/, line, capture: :all_but_first)

      [cmd | argify(args)] |> List.to_tuple
    end)
  end

  def argify(args) do
    args
    |> Enum.map(fn a ->
      case Integer.parse(a) do
        :error -> a
        {int, _} -> int
      end
    end)
  end
end
