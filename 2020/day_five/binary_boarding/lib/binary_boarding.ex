defmodule BinaryBoarding do
  def solve_5_1 do
    "boarding_passes.txt"
    |> organize_boarding_passes_instructions()
    |> compute_IDs()
    |> Enum.sort(:desc)
    |> List.first()
  end

  def solve_5_2 do
    "boarding_passes.txt"
    |> organize_boarding_passes_instructions()
    |> compute_IDs()
    |> Enum.sort()
    |> find_my_seat(nil)
  end

  # PRIVATE

  defp find_my_seat([first | rest], nil) do
    cond do
      List.first(rest) - first == 2 ->
        find_my_seat(rest, first + 1)

      true ->
        find_my_seat(rest, nil)
    end
  end

  defp find_my_seat(_IDs, myID), do: myID

  defp compute_IDs(instructions) do
    instructions
    |> Stream.map(fn [row, column] ->
      [row_nb] = binary_reducer(row, 0..127, {"F", "B"})
      [column_nb] = binary_reducer(column, 0..7, {"L", "R"})
      8 * row_nb + column_nb
    end)
  end

  defp binary_reducer(ins, range, {lower, upper}) do
    ins
    |> Enum.reduce(range, fn i, acc ->
      len = acc |> Enum.count()

      cond do
        i == lower ->
          acc |> Enum.take(div(len, 2))

        i == upper ->
          acc |> Enum.drop(div(len, 2))
      end
    end)
  end

  defp organize_boarding_passes_instructions(filename) do
    filename
    |> get_inputs()
    |> separate_instructions()
  end

  defp separate_instructions(raw) do
    raw
    |> Stream.map(fn bp -> bp |> String.split("", trim: true) end)
    |> Stream.map(fn bp ->
      row = Enum.take(bp, 7)
      column = Enum.drop(bp, 7)
      [row, column]
    end)
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
