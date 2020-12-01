defmodule ExpenseReport do
  def solve_1_1(inputs) do
    [a, b] =
      inputs
      |> get_inputs()
      |> find_matching_nums()

    a * b
  end

  def solve_1_2(inputs) do
    [a, b, c] =
      inputs
      |> get_inputs()
      |> iterate()

    a * b * c
  end

  def iterate([lim | tail]) do
    case find_matching_nums_to(tail, 2020 - lim) do
      [x, y] ->
        [x, y, lim]

      [] ->
        iterate(tail ++ [lim])
    end
  end

  # PRIVATE

  def sum_up_to(x, y, lim) do
    x + y == lim
  end

  defp sum_up(x, y) do
    x + y == 2020
  end

  def find_matching_nums([]) do
    []
  end

  def find_matching_nums([x | nums]) do
    case Enum.filter(nums, fn n -> sum_up(x, n) end) do
      [y] ->
        [x, y]

      [] ->
        find_matching_nums(nums)
    end
  end

  def find_matching_nums_to([], _) do
    []
  end

  def find_matching_nums_to([x | nums], limit) do
    case Enum.filter(nums, fn n -> sum_up_to(x, n, limit) end) do
      [y] ->
        [x, y]

      [] ->
        find_matching_nums_to(nums, limit)
    end
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
