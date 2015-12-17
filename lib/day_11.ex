defmodule Day11 do

  def next_password(string) do
    Stream.iterate(next_password(string, three_ascending?(string), doubles_count(string)),
                   &next_password(&1, three_ascending?(&1), doubles_count(&1)))
    |> Enum.find(&valid?/1)
  end

  def next_password(string, true, n) when n >= 2, do: increment(string)

  def next_password(<< head::size(24), rest::binary>> , false, 0)
  when rest >= "xxyzz" do
    increment(<<head::size(24)>>) <> "aabcc"
  end

  def valid?(string) do
    three_ascending?(string) && (doubles_count(string) >= 2)
  end


  def increment(string) do
    string
    |> String.reverse
    |> do_increment
    |> String.reverse
  end

  def do_increment("z" <> rest), do: "a" <> do_increment(rest)
  def do_increment(<< c::size(8), rest::binary >>) when c in [?i, ?l, ?o] do
    << (c+2)::size(8), rest::binary >>
  end
  def do_increment(<< c::size(8), rest::binary >>), do: << (c+1)::size(8), rest::binary >>

  def doubles_count(string) do
    Regex.scan(~r/(.)\1/, string) |> Enum.count
  end


  @ascending (?a..?z) |> Enum.chunk(3,1) |> Enum.map(&List.to_string/1)

  def three_ascending?(string) do
    @ascending |> Enum.any?(&String.contains?(string, &1))
  end
end
