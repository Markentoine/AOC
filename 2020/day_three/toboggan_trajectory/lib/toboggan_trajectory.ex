defmodule TobogganTrajectory do
  @paces [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
  @pace_1_horizontal 3
  @pace_1_vertical 1

  def solve_3_1 do
    build_map()
    |> Map.put(:pace_horizontal, @pace_1_horizontal)
    |> Map.put(:pace_vertical, @pace_1_vertical)
    |> move()
  end

  def solve_3_2 do
    map = build_map()

    @paces
    |> Enum.map(fn pace -> pace |> move_again(map) end)
    |> Enum.reduce(fn x, acc -> acc * x end)
  end

  # PRIVATE
  defp build_map do
    "plan.txt"
    |> get_inputs()
    |> get_len()
  end

  defp move_again({pace_horizonal, pace_vertical}, map) do
    map
    |> Map.put(:pace_horizontal, pace_horizonal)
    |> Map.put(:pace_vertical, pace_vertical)
    |> move()
  end

  defp move(map) do
    map
    |> move_vertically()
    |> move_horizontally(map.pace_horizontal, 0)
  end

  defp move_vertically(map) do
    [_ | new_plan] =
      cond do
        map.pace_vertical == 1 ->
          map.plan

        true ->
          map.plan |> Enum.take_every(map.pace_vertical)
      end

    Map.replace(map, :plan, new_plan)
  end

  defp move_horizontally(%{plan: []}, _, count), do: count

  defp move_horizontally(%{plan: [row | rest], length: len} = map, index, count) do
    obstacle = row |> String.split("", trim: true) |> Enum.at(index)

    cond do
      obstacle == "#" ->
        map
        |> Map.replace(:plan, rest)
        |> move_horizontally(Integer.mod(index + map.pace_horizontal, len), count + 1)

      true ->
        map
        |> Map.replace(:plan, rest)
        |> move_horizontally(Integer.mod(index + map.pace_horizontal, len), count)
    end
  end

  defp get_len(map) do
    [row | _rest] = map.plan
    len = String.split(row, "", trim: true) |> Enum.count()
    Map.put(map, :length, len)
  end

  defp get_inputs(filename) do
    plan =
      filename
      |> get_path()
      |> File.read!()
      |> String.trim()
      |> String.split("\n")

    %{plan: plan}
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
