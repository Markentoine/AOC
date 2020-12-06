defmodule DayFive.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    extract_data()
    |> Enum.filter(&check_vowels/1)
    |> Enum.filter(&check_double_letters/1)
    |> Enum.reject(&check_combinations/1)
    |> Enum.count()
  end

  def solve_2 do
    extract_data()
    |> Enum.filter(&check_double_double/1)
    |> Enum.filter(&check_reappear/1)
    |> IO.inspect()
    |> Enum.count()
  end

  # PRIVATE
  defp check_reappear(str) do
    Regex.match?(~r/(.).\1/, str)
  end

  defp check_double_double(str) do
    Regex.match?(~r/(.)(.).*\1\2/, str)
  end

  defp check_vowels(str) do
    Regex.match?(~r/[aeiou].*[aeiou].*[aeiou]/, str)
  end

  defp check_double_letters(str) do
    Regex.match?(~r/(.)\1/, str)
  end

  defp check_combinations(str) do
    Regex.match?(~r/ab|cd|pq|xy/, str)
  end

  defp extract_data do
    I.get_lines("five.txt")
  end
end
