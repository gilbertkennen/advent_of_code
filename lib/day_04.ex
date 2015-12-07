defmodule Day04 do
  @moduledoc """
  Today we brute force hashing algorithms to produce a hash with leading zeroes.

  Parts one and two are just different numbers of zeroes, so this solution generalizes finding an arbitrary number of zeroes.

  The match/3 function uses binary pattern matching to find a string with enough leading zeroes. Binary manipulation can sometimes be a bit awkward. In this case, we have to ignore enough bits to eat an entire byte of data, even if we don't need it, thus the 'rem_bits' code.

  The hash/1 function shows how to call Erlang functions. All module names are just atoms, but Elixir modules are actually :'Elixir.ModuleName' with some sugar to make them look nicer. Erlang module names use a different convention, so raw atoms are used.

  A rather crude parallelization scheme is used in `Day04.parallel_hash/2` to spawn a number of Tasks which are automatically distributed among the processing cores. Tasks get spawned then this main process sits in a receive loop until one of them sends a result message and the remaining Tasks are sent exit messages.
  """

  @doc """
  Find an integer string to append to a given key which produces an MD5 hash beginning with the requested number of hexadecimal zeroes.

  Start and step indicate which integer to start on and how many to skip (useful for parallelization).

  # Examples

      iex> Day04.hash("abcdef", 5)
      609043

      iex> Day04.hash("pqrstuv", 5)
      1048970
  """
  @spec hash(String.t, integer, integer, integer) :: integer
  def hash(key, zeroes, start \\ 0, step \\ 1) do
    zero_bits = zeroes * 4
    rem_bits = rem(zeroes, 2) * 4

    Stream.iterate(start, &Kernel.+(&1, step))
    |> Enum.find(&match(key <> Integer.to_string(&1), zero_bits, rem_bits))
  end


  @spec match(String.t, integer, integer) :: integer
  defp match(string, zero_bits, rem_bits) do
    match?( << 0::size(zero_bits), _::size(rem_bits), _::binary >>,
            md5(string))
  end


  @spec md5(String.t) :: binary
  defp md5(string) do
    :crypto.hash(:md5, string)
  end


  @doc """
  `Day04.hash/4`, but with parallel tasks.

  ## Examples

      iex> Day04.hash("abcdef", 5)
      609043

      iex> Day04.hash("pqrstuv", 5)
      1048970
  """
  @spec parallel_hash(String.t, integer) :: integer
  def parallel_hash(key, zeroes) do
    num = :erlang.system_info(:schedulers_online)

    tasks =
      (0..(num-1))
      |> Enum.map(&Task.async(fn -> hash(key, zeroes, &1, num) end))

    await(tasks)
  end


  @spec await(Task.t) :: integer
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
