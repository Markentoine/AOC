defmodule DaySix.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    instructions = normalize_data("six.txt")

    grid =
      build_grid(1000) |> Enum.reduce(%{}, fn coords, grid -> Map.put(grid, coords, false) end)

    execute(instructions, grid) |> Enum.filter(fn {_, lit} -> lit end) |> Enum.count()
  end

  def solve_2 do
  end

  # PRIVATE
  defp execute([], grid) do
    grid
  end

  defp execute([ins | rest], grid) do
    {to_do, [from, to]} = ins
    sub = subgrid(from, to)

    new_grid =
      case to_do do
        :on ->
          sub
          |> Enum.reduce(grid, fn coord, acc ->
            acc |> Map.replace!(coord, true)
          end)

        :off ->
          sub
          |> Enum.reduce(grid, fn coord, acc ->
            acc |> Map.replace!(coord, false)
          end)

        :toggle ->
          sub
          |> Enum.reduce(grid, fn coord, acc ->
            val = Map.fetch!(grid, coord)

            cond do
              val ->
                acc |> Map.replace!(coord, false)

              true ->
                acc |> Map.replace!(coord, true)
            end
          end)
      end

    execute(rest, new_grid)
  end

  defp subgrid({s1, st1}, {s2, st2}) do
    row = s1..s2
    column = st1..st2

    for r <- row, c <- column do
      {r, c}
    end
  end

  defp build_grid(n) do
    row = 0..(n - 1)
    column = 0..(n - 1)

    for r <- row, c <- column do
      {r, c}
    end
  end

  defp normalize_data(filename) do
    lines =
      filename
      |> I.get_lines()

    instructions =
      lines
      |> Enum.map(fn l ->
        [instruction | _] = l |> String.split(~r/\d/, trim: true)

        instruction
        |> String.trim()
        |> turn_to_atom()
      end)

    ranges =
      lines
      |> Enum.map(fn l ->
        [[_, start1, stop1], [_, start2, stop2]] = Regex.scan(~r/(\d+),(\d+)/, l)

        [
          {String.to_integer(start1), String.to_integer(stop1)},
          {String.to_integer(start2), String.to_integer(stop2)}
        ]
      end)

    Enum.zip(instructions, ranges)
  end

  defp turn_to_atom(ins) do
    ins = ins |> String.split(~r/\W/, trim: true)

    case ins do
      ["turn", i] ->
        i |> String.to_atom()

      ["toggle"] ->
        :toggle
    end
  end
end
