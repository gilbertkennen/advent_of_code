defmodule Day08 do
  defp parse_file(filename) do
    filename
    |> File.stream!
    |> Stream.map(&String.rstrip/1)
  end

  def part_one(filename) do
    filename
    |> parse_file
    |> Stream.map(&(String.length(&1) - count(&1)))
    |> Enum.reduce(0, &Kernel.+/2)
  end

  def count("\\\\" <> rest), do: 1 + count(rest)
  def count("\\\"" <> rest), do: 1 + count(rest)
  def count("\"" <> rest), do: count(rest)
  def count("\\x" <> <<_::utf8, _::utf8, rest::binary>>) do
    1 + count(rest)
  end
  def count(<<_::utf8, rest::binary>>), do: 1 + count(rest)
  def count(""), do: 0


  def part_two(filename) do
    filename
    |> parse_file
    |> Stream.map(&(count2(&1) - String.length(&1)))
    |> Enum.reduce(0, &Kernel.+/2)
  end

  def count2("\"" <> rest), do: 2 + count2(rest)
  def count2("\\" <> rest), do: 2 + count2(rest)
  def count2(<<_::utf8, rest::binary>>), do: 1 + count2(rest)
  def count2(""), do: 2
end
