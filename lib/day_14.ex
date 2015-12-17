defmodule Day14 do
  defmodule Reindeer do
    defstruct [:name, :speed, :duration, :rest]
  end

  def part_one(filename, time) do
    filename
    |> parse_file
    |> leaders_at(time)
    |> hd
    |> distance(time)
  end


  def part_two(filename, time) do
    reindeer =
      filename
    |> parse_file

    (1..time)
    |> Enum.reduce(%{}, fn sec, acc ->
      leaders_at(reindeer, sec)
      |> increment_scores(acc)
    end)
    |> Map.values
    |> Enum.max
  end


  def increment_scores(leaders, acc) do
    leaders
    |> Enum.reduce(acc, fn r, acc ->
      Map.update(acc, r.name, 1, &(&1 + 1))
    end)
  end


  def leaders_at(reindeer, time) do
    rankings = reindeer |> Enum.sort_by(&(distance(&1, time) * -1))
    lead_distance = rankings |> hd |> distance(time)
    rankings |> Enum.take_while(&(distance(&1, time) == lead_distance))
  end


  def distance(%{duration: duration, speed: speed, rest: rest}, time) do
    full_cycles = div(time, duration + rest) * duration
    last_cycle = Enum.min([rem(time, duration + rest), duration])

    (full_cycles + last_cycle) * speed
  end


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Enum.map(fn line ->
      [_, name, speed, duration, rest] =
        Regex.run(~r/(\w+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)/, line)

      %Reindeer{
        name: name,
        speed: String.to_integer(speed),
        duration: String.to_integer(duration),
        rest: String.to_integer(rest)
      }
    end)
  end
end
