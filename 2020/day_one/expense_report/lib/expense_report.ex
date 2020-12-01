defmodule ExpenseReport do
  def solve_1_1(inputs) do
    [a, b] =
      inputs
      |> get_inputs()
      |> find_matching_nums()

    a * b
  end

  # PRIVATE

  defp sum_up(x, y) do
    x + y == 2020
  end

  def find_matching_nums([x | nums]) do
    case filter(x, nums) do
      [y] ->
        [x, y]

      [] ->
        find_matching_nums(nums)
    end
  end

  def filter(x, nums) do
    nums
    |> Enum.filter(fn n -> sum_up(x, n) end)
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
