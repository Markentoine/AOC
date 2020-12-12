defmodule DayEleven.Puzzle do
  alias Inputs.GetInputs, as: I
  alias Datastructures.Build, as: B

  def solve_1 do
    "eleven.txt"
    |> get_raw_data()
    |> build_datastructure()
    |> add_neighbors()
    |> change_state(false)
  end

  def solve_2 do
    "eleven.txt"
    |> get_raw_data()
    |> build_datastructure()
    |> add_visible_seats()
    |> change_state_new_rules(false)
  end

  # PRIVATE
  defp change_state_new_rules(seats, true) do
    # IO.puts("here")
    # seats |> Enum.map(fn {_, {seat, _}} -> seat end) |> IO.inspect()
    seats |> Enum.count(fn {_, {seat, _}} -> seat == "#" end)
  end

  defp change_state_new_rules(seats, false) do
    seats |> Enum.count(fn {_, {seat, _}} -> seat == "#" end) |> IO.inspect()

    {new_seats, stable} =
      seats
      |> Enum.reduce({%{}, true}, fn {coords, {seat_state, visible_seats}}, {result, stable} ->
        new_seat_state =
          case seat_state do
            "L" ->
              if no_neighbors?(visible_seats, seats) do
                "#"
              else
                "L"
              end

            "#" ->
              if too_much?(visible_seats, seats, 5) do
                "L"
              else
                "#"
              end
          end

        cond do
          seat_state != new_seat_state ->
            {Map.put(result, coords, {new_seat_state, visible_seats}), false}

          true ->
            {Map.put(result, coords, {new_seat_state, visible_seats}), stable}
        end
      end)

    new_seats |> change_state_new_rules(stable)
  end

  defp add_visible_seats({layout, lenX, lenY}) do
    layout
    |> Enum.reduce(%{}, fn {coords, state}, result ->
      result
      |> Map.put(
        coords,
        {state, Enum.reject(visible_seats(coords, layout, lenX, lenY), &is_nil/1)}
      )
    end)
    |> Enum.reject(fn {_, {seat_state, _}} -> seat_state == "." end)
    |> Enum.into(%{})
  end

  defp visible_seats(origin, layout, maxX, maxY) do
    directions = [
      {:same, :up},
      {:front, :up},
      {:front, :same},
      {:front, :down},
      {:same, :down},
      {:back, :down},
      {:back, :same},
      {:back, :up}
    ]

    directions
    |> Enum.map(fn dir ->
      seat_in_direction(dir, layout, origin, maxX, maxY)
      |> Enum.find(fn s ->
        seat_state = Map.fetch!(layout, s)
        seat_state == "L"
      end)
    end)
  end

  def seat_in_direction(direction, seats, {x, y}, maxX, maxY) do
    case direction do
      {:same, :up} ->
        cond do
          y == maxY - 1 ->
            [{nil, nil}]

          true ->
            for y <- (y + 1)..(maxY - 1), x <- [x] do
              {x, y}
            end
        end

      {:front, :up} ->
        cond do
          x == maxX - 1 or y == maxY - 1 ->
            [{nil, nil}]

          true ->
            Enum.zip((x + 1)..(maxX - 1), (y + 1)..(maxY - 1))
        end

      {:front, :same} ->
        cond do
          x == maxX - 1 ->
            [{nil, nil}]

          true ->
            for x <- (x + 1)..(maxX - 1), y <- [y] do
              {x, y}
            end
        end

      {:front, :down} ->
        cond do
          x == maxX - 1 or y == 0 ->
            [{nil, nil}]

          true ->
            Enum.zip((x + 1)..(maxX - 1), (y - 1)..0)
        end

      {:same, :down} ->
        cond do
          y == 0 ->
            [{nil, nil}]

          true ->
            for y <- (y - 1)..0, x <- [x] do
              {x, y}
            end
        end

      {:back, :down} ->
        cond do
          x == 0 or y == 0 ->
            [{nil, nil}]

          true ->
            Enum.zip((x - 1)..0, (y - 1)..0)
        end

      {:back, :same} ->
        cond do
          x == 0 ->
            [{nil, nil}]

          true ->
            for x <- (x - 1)..0, y <- [y] do
              {x, y}
            end
        end

      {:back, :up} ->
        cond do
          x == 0 or y == maxY - 1 ->
            [{nil, nil}]

          true ->
            Enum.zip((x - 1)..0, (y + 1)..(maxY - 1))
        end
    end
    |> Enum.reject(fn {x, y} ->
      is_nil(x) or Map.fetch!(seats, {x, y}) == "."
    end)
    |> Enum.filter(fn {x, y} ->
      x >= 0 and y >= 0 and x < maxX and y < maxY
    end)
  end

  defp change_state(seats, true) do
    seats |> Enum.count(fn {_, {seat, _}} -> seat == "#" end)
  end

  defp change_state(seats, false) do
    {new_seats, stable} =
      seats
      |> Enum.reduce({%{}, true}, fn {coords, {seat_state, nbors}}, {result, stable} ->
        new_seat_state =
          case seat_state do
            "L" ->
              if no_neighbors?(nbors, seats) do
                "#"
              else
                "L"
              end

            "#" ->
              if too_much?(nbors, seats) do
                "L"
              else
                "#"
              end
          end

        cond do
          seat_state != new_seat_state ->
            {Map.put(result, coords, {new_seat_state, nbors}), false}

          true ->
            {Map.put(result, coords, {new_seat_state, nbors}), stable}
        end
      end)

    new_seats |> change_state(stable)
  end

  defp too_much?(ns, seats, max \\ 4) do
    ns
    |> Enum.filter(fn n ->
      {seat_state, _} = Map.fetch!(seats, n)
      seat_state == "#"
    end)
    |> Enum.count() >= max
  end

  defp no_neighbors?(ns, seats) do
    ns
    |> Enum.filter(fn n ->
      {seat_state, _} = seats |> Map.fetch!(n)
      seat_state == "#"
    end)
    |> Enum.count() == 0
  end

  defp neighbors({x, y}, layout, x_max, y_max) do
    xl = x - 1
    xr = x + 1
    yu = y - 1
    yd = y + 1

    all_possible_neighbors = [
      {xl, y},
      {xl, yu},
      {x, yu},
      {xr, yu},
      {xr, y},
      {xr, yd},
      {x, yd},
      {xl, yd}
    ]

    all_possible_neighbors
    |> Enum.filter(fn {x, y} ->
      x >= 0 and y >= 0 and x < x_max and y < y_max
    end)
    |> Enum.reject(fn {x, y} ->
      Map.fetch!(layout, {x, y}) == "."
    end)
  end

  defp add_neighbors({layout, lenX, lenY}) do
    layout
    |> Enum.reduce(%{}, fn {coords, state}, result ->
      result |> Map.put(coords, {state, neighbors(coords, layout, lenX, lenY)})
    end)
    |> Enum.reject(fn {_, {state, _}} -> state == "." end)
    |> Enum.into(%{})
  end

  defp build_datastructure([row | _] = occupation) do
    lenX = Enum.count(occupation) |> IO.inspect(label: "x_max")
    lenY = Enum.count(row) |> IO.inspect(label: "y_max")
    occupation_inlined = occupation |> Enum.reduce(fn l, acc -> Enum.concat(acc, l) end)
    map_seats = B.map_coords(occupation_inlined, lenX, lenY)

    {map_seats, lenX, lenY}

    # %{
    #  {3, 3} => {"L", [{2, 2}, {3, 2}, {4, 2}, {4, 3}, {2, 4}]},
    #  {7, 6} => {"L", [{7, 5}, {8, 5}, {8, 6}, {8, 7}, {7, 7}]},
    # ... }
  end

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
    |> I.decompose_lines()
  end
end
