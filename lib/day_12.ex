defmodule Day12 do
    def part_one(string) do
   Regex.scan(~r/-?\d+/, string)
   |> Enum.map(fn [s] -> s |> Integer.parse |> elem(0) end)
   |> Enum.reduce(0, &Kernel.+/2)
 end

 def part_two(string) do
   string
   |> String.split("{")
   |> do_part_two(0)
   |> elem(1)
 end

 defp do_part_two([""], n), do: {[""], n}
 defp do_part_two([h | t], n) do
   case String.split(h, "}", parts: 2) do

     [str] ->
       {[new_h | new_t], num} = do_part_two(t, 0)
       do_part_two([str <> new_h | new_t], n + num)

     [h2 , t2] ->
       if String.contains?(h2, ":\"red\"") do
         {[t2 | t], 0}
       else
         {[t2 | t], n + part_one(h2)}
       end

   end
 end
end
