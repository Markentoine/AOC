defmodule DaySix.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    instructions = normalize_data("six.txt")

    grid =
      build_grid(1000) |> Enum.reduce(%{}, fn coords, grid -> Map.put(grid, coords, false) end)

    execute(instructions, grid, [&turn/3, &toogle/2], &rebuild_grid/4)
    |> Enum.filter(fn {_, lit} -> lit end)
    |> Enum.count()
  end

  def solve_2 do
    instructions = normalize_data("six.txt")

    grid = build_grid(1000) |> Enum.reduce(%{}, fn coords, grid -> Map.put(grid, coords, 0) end)

    execute(instructions, grid, [&increase/3], &change_brightness/4)
    |> Map.values()
    |> Enum.sum()
  end

  # PRIVATE
  defp execute([], grid, _, _) do
    grid
  end

  defp execute([ins | rest], grid, funs, fun3) do
    {to_do, [from, to]} = ins
    sub = subgrid(from, to)

    new_grid = fun3.(to_do, sub, grid, funs)

    execute(rest, new_grid, funs, fun3)
  end

  defp change_brightness(todo, sub, grid, funs) do
    [fun1] = funs

    case todo do
      :on ->
        fun1.(sub, grid, 1)

      :off ->
        fun1.(sub, grid, -1)

      :toggle ->
        fun1.(sub, grid, 2)
    end
  end

  defp increase(sub, grid, amount) do
    sub
    |> Enum.reduce(grid, fn coord, acc ->
      val = Map.fetch!(grid, coord)

      new_val =
        if val + amount < 0 do
          0
        else
          val + amount
        end

      acc |> Map.replace!(coord, new_val)
    end)
  end

  def rebuild_grid(todo, sub, grid, funs) do
    [fun1, fun2] = funs

    case todo do
      :on ->
        fun1.(sub, grid, true)

      :off ->
        fun1.(sub, grid, false)

      :toggle ->
        fun2.(sub, grid)
    end
  end

  defp turn(subgrid, grid, opt) do
    subgrid
    |> Enum.reduce(grid, fn coord, acc ->
      acc |> Map.replace!(coord, opt)
    end)
  end

  defp toogle(sub, grid) do
    sub
    |> Enum.reduce(grid, fn coord, acc ->
      val = Map.fetch!(grid, coord)
      acc |> Map.replace!(coord, !val)
    end)
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
