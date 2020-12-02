defmodule PwdPhilosophy do
  def solve_2_1, do: solve(&match_policy/1)

  def solve_2_2, do: solve(&match_real_policy/1)

  # PRIVATE
  defp solve(fun) do
    "pwd_db.txt"
    |> get_inputs()
    |> serialize_pwd_infos()
    |> Enum.filter(fun)
    |> Enum.count()
  end

  defp match_real_policy(%{letter: letter, range: range, pwd: pwd}) do
    [pos1, pos2] = range(range)
    list_chars = pwd |> String.split("", trim: true)
    char1 = Enum.at(list_chars, pos1 - 1)
    char2 = Enum.at(list_chars, pos2 - 1)
    !(char1 == letter and char2 == letter) and (char1 == letter or char2 == letter)
  end

  defp serialize_pwd_infos(rows) do
    rows
    |> Enum.map(&pwd_infos/1)
    |> Enum.map(fn [range, letter, pwd] ->
      %{range: range, letter: extract_letter(letter), pwd: pwd}
    end)
  end

  def extract_letter(str) do
    {letter, _} = str |> String.split_at(1)
    letter
  end

  defp range(range) do
    range |> String.split("-") |> Enum.map(&String.to_integer/1) |> Enum.sort()
  end

  defp count_letter(pwd, letter) do
    Enum.count(String.split(pwd, ""), fn l -> l == letter end)
  end

  def match_policy(%{letter: letter, range: range, pwd: pwd}) do
    [min, max] = range(range)
    count = count_letter(pwd, letter)
    count >= min and count <= max
  end

  defp pwd_infos(row) do
    row
    |> String.split(~r/\s/)
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
