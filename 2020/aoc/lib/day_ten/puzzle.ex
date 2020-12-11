defmodule DayTen.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    joltages =
      "ten.txt"
      |> get_raw_data()
      |> Stream.map(&String.to_integer/1)
      |> Enum.sort()

    result = [0 | joltages] |> test_adaptater([])
    ones = result |> Enum.filter(&(&1 == 1)) |> Enum.count()
    threes = result |> Enum.filter(&(&1 == 3)) |> Enum.count()
    ones * threes
  end

  def solve_2 do
    joltages =
      "ten.txt"
      |> get_raw_data()
      |> Stream.map(&String.to_integer/1)
      |> Enum.sort()

    # |> IO.inspect(charlists: :lists)

    [0 | joltages] |> count_all_possible_paths([])
  end

  # PRIVATE

  defp count_all_possible_paths([_n, _n1 | []], lut) do
    IO.inspect(lut, label: "lut")
    lut |> Enum.reduce(0, fn {_, _, edges}, acc -> acc + edges end)
  end

  defp count_all_possible_paths([n, n1, n2 | []], lut) do
    possible_path = [n + 1, n + 2, n + 3]
    sure_paths = [n1, n2] |> Enum.filter(fn n -> Enum.member?(possible_path, n) end)
    filtered_lut = lut |> Enum.reject(fn {_, nb, _} -> nb == n end)

    new_edges =
      lut
      |> Enum.filter(fn {_, nb, _} -> nb == n end)
      |> Enum.reduce(0, fn {_, _, edges}, acc -> acc + edges end)

    cond do
      Enum.count(sure_paths) == 1 ->
        [nxt] = sure_paths
        new_lut = [{n, nxt, new_edges} | filtered_lut]
        count_all_possible_paths([n1, n2 | []], new_lut)

      Enum.count(sure_paths) == 2 ->
        [nxt, nnxt] = sure_paths
        new_lut = [{n, nxt, new_edges}, {n, nnxt, new_edges} | filtered_lut]
        count_all_possible_paths([n1, n2 | []], new_lut)
    end
  end

  defp count_all_possible_paths([n, n1, n2, n3 | tail], [] = lut) do
    possible_path = [n + 1, n + 2, n + 3]
    sure_paths = [n1, n2, n3] |> Enum.filter(fn n -> Enum.member?(possible_path, n) end)

    cond do
      Enum.count(sure_paths) == 1 ->
        [nxt] = sure_paths
        new_lut = [{n, nxt, 1} | lut]
        IO.inspect(new_lut, label: "newlut")
        count_all_possible_paths([n1, n2, n3 | tail], new_lut)

      Enum.count(sure_paths) == 2 ->
        [nxt, nnxt] = sure_paths
        new_lut = [{n, nxt, 1}, {n, nnxt, 1} | lut]
        IO.inspect(new_lut, label: "newlut")
        count_all_possible_paths([n1, n2, n3 | tail], new_lut)

      Enum.count(sure_paths) == 3 ->
        [nxt, nnxt, nnnxt] = sure_paths
        new_lut = [{n, nxt, 1}, {n, nnxt, 1}, {n, nnnxt, 1} | lut]
        IO.inspect(new_lut, label: "newlut")
        count_all_possible_paths([n1, n2, n3 | tail], new_lut)
    end
  end

  defp count_all_possible_paths([n, n1, n2, n3 | tail], lut) do
    IO.inspect(lut, label: "lut")

    new_edges =
      lut
      |> Enum.filter(fn {_, nb, _} -> nb == n end)
      |> Enum.reduce(0, fn {_, _, edges}, acc -> acc + edges end)

    possible_path = [n + 1, n + 2, n + 3]
    sure_paths = [n1, n2, n3] |> Enum.filter(fn n -> Enum.member?(possible_path, n) end)
    filtered_lut = lut |> Enum.reject(fn {_, nb, _} -> nb == n end)

    cond do
      Enum.count(sure_paths) == 1 ->
        [nxt] = sure_paths
        new_lut = [{n, nxt, new_edges} | filtered_lut]
        count_all_possible_paths([n1, n2, n3 | tail], new_lut)

      Enum.count(sure_paths) == 2 ->
        [nxt, nnxt] = sure_paths
        new_lut = [{n, nxt, new_edges}, {n, nnxt, new_edges} | filtered_lut]
        count_all_possible_paths([n1, n2, n3 | tail], new_lut)

      Enum.count(sure_paths) == 3 ->
        [nxt, nnxt, nnnxt] = sure_paths

        new_lut = [
          {n, nxt, new_edges},
          {n, nnxt, new_edges},
          {n, nnnxt, new_edges} | filtered_lut
        ]

        count_all_possible_paths([n1, n2, n3 | tail], new_lut)
    end
  end

  defp test_adaptater([], acc) do
    acc
  end

  defp test_adaptater([source | rest], acc) do
    if Enum.member?(rest, source + 1) do
      new_acc = [1 | acc]
      test_adaptater(rest, new_acc)
    else
      new_acc = [3 | acc]
      test_adaptater(rest, new_acc)
    end
  end

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
  end
end
