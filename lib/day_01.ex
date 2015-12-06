defmodule ParensCounter do

  def final_floor(parens_string) do
    parens_string
    |> floor_stream
    |> Enum.reduce(0, fn n, _ -> n end)
  end


  def first_basement(parens_string) do
    parens_string
    |> floor_stream
    |> Enum.find_index(&(&1 < 0))
    |> Kernel.+(1)
  end


  defp floor_stream(parens_string) do
    parens_string
    |> String.graphemes
    |> Stream.scan(0, fn
         "(", acc -> acc + 1
         ")", acc -> acc - 1
       end)
  end

end
