defmodule SantaAnalyzer do

  def nice?(string) do
    !String.match?(string, ~r/ab|cd|pq|xy/) &&
    String.match?(string, ~r/([aeiou].*){3}/) &&
    String.match?(string, ~r/(.)\1/)
  end


  def two_nice?(string) do
    String.match?(string, ~r/(..).*\1/) &&
    String.match?(string, ~r/(.).\1/)
  end

end
