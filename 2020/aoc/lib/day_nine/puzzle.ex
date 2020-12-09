defmodule DayNine.Puzzle do
  alias Inputs.GetInputs, as: I

  @len 25

  def solve_1 do
    raw_data =
      "nine.txt"
      |> get_raw_data()
      |> Enum.map(&String.to_integer/1)

    check_invalid(Enum.drop(raw_data, @len), raw_data)
  end

  def solve_2 do
    raw_data =
      "nine.txt"
      |> get_raw_data()
      |> Enum.map(&String.to_integer/1)

    invalid_nb = Enum.drop(raw_data, @len) |> check_invalid(raw_data)
    find_contiguous_nbs(invalid_nb, raw_data)
  end

  # PRIVATE
  defp find_contiguous_nbs(n, [first | tail] = nums) do
    case add_to_limit(nums, 0, [], n) do
      [] ->
        find_contiguous_nbs(n, tail)

      result ->
        result = result |> Enum.sort()
        List.first(result) + List.last(result)
    end
  end

  defp add_to_limit([n | rest], acc, nums, lim) do
    cond do
      n + acc < lim ->
        add_to_limit(rest, n + acc, [n | nums], lim)

      n + acc > lim ->
        []

      n + acc == lim ->
        nums
    end
  end

  defp check_invalid([first | rest], [_ | tail] = origin) do
    pre = origin |> get_preamble(@len)
    possible = all_possible_sums(pre, [])

    cond do
      check_valid_number(first, possible) ->
        check_invalid(rest, tail)

      true ->
        first
    end
  end

  defp check_valid_number(number, possible_numbers) do
    possible_numbers |> Enum.member?(number)
  end

  defp all_possible_sums([], acc) do
    acc
  end

  defp all_possible_sums([first | rest], acc) do
    sums = rest |> Enum.map(fn n -> n + first end)
    all_possible_sums(rest, sums ++ acc)
  end

  defp get_numbers(data, len) do
    data |> Enum.drop(len)
  end

  defp get_preamble(data, len) do
    data |> Enum.take(len)
  end

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
  end
end
