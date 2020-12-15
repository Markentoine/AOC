defmodule DayTwelve.Puzzle do
  alias Inputs.GetInputs, as: I
  alias DayTwelve.Boat
  alias DayTwelve.Waypoint

  @directions [:E, :W, :S, :N]

  def solve_1 do
    new_boat = Boat.new()

    "twelve.txt"
    |> get_raw_data()
    |> get_instructions()
    |> command(new_boat)
  end

  def solve_2 do
    new_boat = Boat.new()
    waypoint = %{E: 10, N: 1, S: 0, W: 0}

    "twelve.txt"
    |> get_raw_data()
    |> get_instructions()
    |> navigate(new_boat, waypoint)
  end

  # PRIVATE
  defp navigate([], boat, _waypoint) do
    manhattan_distance(boat)
  end

  defp navigate([{ins, times} | tail], boat, waypoint) when ins == :F do
    new_boat =
      waypoint
      |> Enum.reduce(boat, fn {dir, pos}, new_boat ->
        change_pos(dir, pos * times, new_boat)
      end)

    navigate(tail, new_boat, waypoint)
  end

  defp navigate([{ins, degrees} | tail], boat, waypoint) when ins == :L do
    navigate(tail, boat, stir(waypoint, degrees, :ccw))
  end

  defp navigate([{ins, degrees} | tail], boat, waypoint) when ins == :R do
    navigate(tail, boat, stir(waypoint, degrees, :cw))
  end

  defp navigate([{ins, steps} | tail], boat, waypoint)
       when ins == :N or ins == :S or ins == :E or ins == :W do
    new_waypoint = change_pos(ins, steps, waypoint)
    navigate(tail, boat, new_waypoint)
  end

  defp stir(waypoint, degrees, clock) do
    1..div(degrees, 90)
    |> Enum.reduce(waypoint, fn _, wp ->
      wp
      |> Enum.reduce(%{E: 0, N: 0, S: 0, W: 0}, fn {dir, pos}, nwp ->
        new_dir = turn(clock, dir)
        Map.replace(nwp, new_dir, pos)
      end)
    end)
  end

  defp manhattan_distance(boat) do
    e = Map.fetch!(boat, :E)
    w = Map.fetch!(boat, :W)
    n = Map.fetch!(boat, :N)
    s = Map.fetch!(boat, :S)
    abs(e - w) + abs(n - s)
  end

  defp command([], boat) do
    boat |> manhattan_distance()
  end

  defp command([{i, n} | tail], boat) do
    new_boat =
      boat
      |> move(i, n)

    command(tail, new_boat)
  end

  defp move(boat, ins, nb) do
    cond do
      Enum.member?(@directions, ins) ->
        change_pos(ins, nb, boat)

      ins == :F ->
        facing_dir = Map.fetch!(boat, :dir)
        change_pos(facing_dir, nb, boat)

      ins == :R ->
        facing_dir = Map.fetch!(boat, :dir)
        rotate(boat, nb, facing_dir, :cw)

      ins == :L ->
        facing_dir = Map.fetch!(boat, :dir)
        rotate(boat, nb, facing_dir, :ccw)
    end
  end

  defp rotate(boat, degrees, facing, clock) do
    new_facing_dir = 1..div(degrees, 90) |> Enum.reduce(facing, fn _, dir -> turn(clock, dir) end)
    Map.replace(boat, :dir, new_facing_dir)
  end

  defp turn(:ccw, origin) do
    case origin do
      :E ->
        :N

      :N ->
        :W

      :W ->
        :S

      :S ->
        :E
    end
  end

  defp turn(:cw, origin) do
    case origin do
      :E ->
        :S

      :S ->
        :W

      :W ->
        :N

      :N ->
        :E
    end
  end

  defp change_pos(dir, steps, boat) do
    opp = %{E: :W, N: :S, W: :E, S: :N}
    antipos = Map.fetch!(boat, opp[dir])
    pos = Map.fetch!(boat, dir)
    counter = antipos - steps

    cond do
      counter >= 0 ->
        Map.replace(boat, opp[dir], counter)

      counter < 0 ->
        Map.replace(boat, opp[dir], 0)
        |> Map.replace(dir, pos + abs(counter))
    end
  end

  defp get_instructions(lines) do
    lines
    |> Stream.map(fn l ->
      Regex.split(~r/(\d+)/, l, include_captures: true, trim: true)
    end)
    |> Enum.map(fn [i, n] -> {String.to_atom(i), String.to_integer(n)} end)
  end

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
  end
end
