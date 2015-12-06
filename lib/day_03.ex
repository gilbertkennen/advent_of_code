defmodule SantaTracker do

  def santa(path_string) do
    path_string
    |> String.graphemes
    |> Stream.scan({0,0}, &move/2)
    |> count
  end


  def robo_santa(path_string) do
    path_string
    |> String.graphemes
    |> Stream.scan({{0,0}, {0,0}}, fn
         dir, {curr, other} -> {other, move(dir, curr)}
       end)
    |> Stream.map(&elem(&1, 1))
    |> count
  end


  defp move("^", {x, y}), do: {x, y+1}

  defp move("v", {x, y}), do: {x, y-1}

  defp move(">", {x, y}), do: {x+1, y}

  defp move("<", {x, y}), do: {x-1, y}


  defp count(visits) do
    visits
    |> Enum.into([{0,0}])
    |> Enum.uniq
    |> Enum.count
  end

end
