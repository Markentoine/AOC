defmodule DayOne do
  def solve_1_1 do
    "directions.txt"
    |> get_inputs()
    |> String.split("", trim: true)
    |> Enum.reduce(0, fn i, floor ->
      cond do
        i == "(" ->
          floor + 1

        i == ")" ->
          floor - 1
      end
    end)
  end

  def solve_1_2 do
    "directions.txt"
    |> get_inputs()
    |> String.split("", trim: true)
    |> basement(0, 0)
  end

  def basement([], _index, floor), do: floor

  def basement(_directions, index, -1), do: index

  def basement(directions, index, floor) do
    [dir | rest] = directions

    cond do
      dir == "(" ->
        basement(rest, index + 1, floor + 1)

      dir == ")" ->
        basement(rest, index + 1, floor - 1)
    end
  end

  # PRIVATE
  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
