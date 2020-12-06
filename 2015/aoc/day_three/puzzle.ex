defmodule DayThree.Challenge do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    extract_data()
  end

  def solve_2 do
  end

  # PRIVATE

  defp extract_data do
    I.get_char("three.txt")
  end

  defp coords_houses([], visited), do: visited

  defp coords_houses([ins | rest], visited(/ / [0, 0])) do
  end
end
