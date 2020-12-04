defmodule DayTwo do
  def solve_2_1 do
    "dimensions.txt"
    |> get_inputs()
    |> Enum.reduce(0, &paper_command/2)
  end

  def solve_2_2 do
    "dimensions.txt"
    |> get_inputs()
    |> Enum.reduce(0, &ribbon_command/2)
  end

  # PRIVATE

  defp ribbon_command(dims, total) do
    [{l, _}, {w, _}, {h, _}] = Enum.map(dims, &Integer.parse/1)
    [d1, d2, _] = [l, w, h] |> Enum.sort()
    smallest_perimeter = 2 * d1 + 2 * d2
    volume = l * w * h
    total + smallest_perimeter + volume
  end

  defp paper_command(dims, total) do
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
