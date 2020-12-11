defmodule DayEleven.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    "eleven_test.txt"
    |> get_raw_data()
  end

  def solve_2 do
  end

  # PRIVATE

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
  end
end
