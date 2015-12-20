defmodule Day19 do
  def part_one(filename) do
    {molecule, substitutions} =
      filename |> parse_file

    molecule
    |> moves(substitutions)
  end

  # def moves(molecule, subs) do
  #   back_refs = sub_backrefs(subs)

  #   subs
  #   |> Enum.reduce(0, fn sub, acc ->
  #     molecule
  #     |> matches(sub, back_refs)
  #     |> length
  #     |> Kernel.+(acc)
  #   end)
  # end


  # def sub_backrefs(substitutions) do
  #   substitutions
  #   |> Enum.reduce(%{}, fn
  #     {input, output}, acc ->
  #       case Regex.scan(~r/[A-Z][a-z]?/, output) do
  #         [[^input], [r]] ->
  #           Map.update(acc, r, [input], &([input | &1]))
  #         _ -> acc
  #       end
  #   end)
  # end

  # def matches(molecule, {input, output}, back_refs) do
  #   [output_prefix, output_suffix] =
  #     Regex.run(~r/^([A-Z][a-z]?)(.*)$/, output, capture: :all_but_first)

  #   refs =
  #     if input == output_suffix do
  #       back_refs[output_prefix]
  #     else
  #       nil
  #     end

  #   IO.inspect{input, output, refs}

  #   case refs do
  #     nil -> input
  #     refs -> ~s/((?:#{Enum.join(refs, "|")})#{output_prefix}*)?#{input}/
  #   end
  #   |> Regex.compile!
  #   |> Regex.scan(molecule)
  #   |> IO.inspect
  #   |> Enum.filter(fn [_|t] ->
  #     Enum.join(t, "") == ""
  #   end)


  # end


  def moves(molecule, substitutions) do
    substitutions
    |> Enum.flat_map(fn {input, output} ->
      replacements(molecule |> to_char_list,
                   input |> to_char_list,
                   output |> to_char_list)
    end)
    |> Enum.uniq
    |> Enum.count
  end

  def replacements(molecule, input, output) do
    replacements(molecule, input, output, [], [])
  end

  def replacements([], _, _, _, acc), do: acc
  def replacements([h | t] = molecule, input, output, header, acc) do
    if :lists.prefix(input, molecule) do
      result =
        :lists.reverse(
          header,
          output ++ (molecule |> Enum.drop(input |> length))
        )
      acc = [result | acc]
    end
    replacements(t, input, output, [h | header], acc)
  end


  def part_two(filename) do
    {molecule, _} = filename |> parse_file

    Regex.replace(~r/Rn|Ar|Y[A-Z]|[a-z]/, molecule, "")
    |> String.length
    |> Kernel.-(1)
  end


  def parse_file(filename) do

    [substitutions, molecule] =
      filename
      |> File.read!
      |> String.split("\n\n")

    substitutions =
      substitutions
      |> String.split("\n")
      |> Enum.map(fn line ->
        [input , outputs] =
          String.split(line, " => ")
        {input, outputs}
      end)

    molecule = molecule |> String.rstrip

    {molecule, substitutions}
  end
end
