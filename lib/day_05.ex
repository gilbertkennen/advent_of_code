defmodule Day05 do

  def part_one do
    File.stream!
    |> Stream.filter(&one_nice?/1)
    |> Enum.count
  end


  defp one_nice?(string) do
    !String.match?(string, ~r/ab|cd|pq|xy/) &&
    String.match?(string, ~r/(.*[aeiou]){3}/) &&
    String.match?(string, ~r/(.)\1/)
  end


  def part_two do
    File.stream!
    |> Stream.filter(&two_nice?/1)
    |> Enum.count
  end


  defp two_nice?(string) do
    String.match?(string, ~r/(..).*\1/) &&
    String.match?(string, ~r/(.).\1/)
  end

end
