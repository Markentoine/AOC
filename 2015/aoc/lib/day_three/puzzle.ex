defmodule DayThree.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    extract_data()
    |> houses_visited()
    |> Enum.count()
  end

  def solve_2 do
    raw_data = extract_data()
    santa = Enum.take_every(raw_data, 2)
    robot = Enum.drop_every(raw_data, 2)
    houses_visited_by_santa = santa |> houses_visited()
    houses_visited_by_robot = robot |> houses_visited()

    (houses_visited_by_santa ++ houses_visited_by_robot)
    |> Enum.uniq()
    |> Enum.count()
  end

  # PRIVATE

  defp houses_visited(data) do
    data
    |> coords_houses([0, 0], [[0, 0]])
    |> Enum.uniq()
  end

  defp extract_data do
    I.get_chars("three.txt")
  end

  defp coords_houses([], _, visited), do: visited

  defp coords_houses([ins | rest], current_pos, visited) do
    [x, y] = current_pos
    IO.inspect(ins)

    house_visited =
      case ins do
        "^" ->
          [x + 1, y]

        "v" ->
          [x - 1, y]

        ">" ->
          [x, y + 1]

        "<" ->
          [x, y - 1]
      end

    coords_houses(rest, house_visited, [house_visited | visited])
  end
end
