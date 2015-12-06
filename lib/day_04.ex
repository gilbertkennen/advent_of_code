defmodule SantaHash do

  def hash(key, zeroes, start \\ 0, skip \\ 1) do
    zero_bits = zeroes * 4
    rem_bits = rem(zeroes, 2) * 4

    Stream.iterate(start, &Kernel.+(&1, skip))
    |> Enum.find(&match(key <> Integer.to_string(&1), zero_bits, rem_bits))
  end


  defp match(string, zero_bits, rem_bits) do
    match?( << 0::size(zero_bits), _::size(rem_bits), _::binary >>,
            hash(string))
  end


  defp hash(string) do
    :crypto.hash(:md5, string)
  end


  def parallel_hash(key, zeroes) do
    num = :erlang.system_info(:schedulers_online)

    tasks =
      (0..(num-1))
      |> Enum.map(&Task.async(fn -> hash(key, zeroes, &1, num) end))

    await(tasks)
  end


  defp await(tasks) do
    receive do

      message ->

        case Task.find(tasks, message) do

          {reply, _task} ->
            Enum.each(tasks, &Process.exit(&1.pid, :normal))
            reply

          nil -> await(tasks)

        end
    end
  end

end
