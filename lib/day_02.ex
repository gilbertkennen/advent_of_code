defmodule WrappingPaper do

  def paper_area(dim) do
    [a, b, c] = Enum.sort(dim)
    3*a*b + 2*a*c + 2*b*c
  end


  def ribbon_length(dim) do
    [a, b, c] = Enum.sort(dim)
    2*a + 2*b + a*b*c
  end


  def parse_file(filename) do
    filename
    |> File.stream!
    |> Stream.map(fn line ->
      line
      |> String.rstrip
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)
    end)
  end

end
