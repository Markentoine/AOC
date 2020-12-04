defmodule DayTwo do
  def solve_2_1 do
    "dimensions.txt"
    |> get_inputs()
    |> Enum.reduce(0, &sum/2)
  end

  # PRIVATE

  defp sum(dims, total) do
    [{l, _}, {w, _}, {h, _}] = Enum.map(dims, &Integer.parse/1)
    s1 = l * w
    s2 = w * h
    s3 = h * l
    areas = [s1, s2, s3]
    total + 2 * Enum.sum(areas) + Enum.min(areas)
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Stream.map(fn dims -> String.split(dims, "x", trim: true) end)
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
