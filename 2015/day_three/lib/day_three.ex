defmodule DayThree do
  def solve_3_1 do
    "directions.txt"
    |> get_inputs()
  end

  # PRIVATE
  defp coords_houses([], visited), do: visited

  defp coords_houses([ins | rest], visited(/ / [0, 0])) do
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("", trim: true)
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
