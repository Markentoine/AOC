defmodule DaySeventeen.Puzzle do
  alias Inputs.GetInputs, as: I
  @filename "seventeen.txt"
  @active "#"
  @inactive "."

  def solve_1 do
    state =
      initialize()
      |> go_cycle(6)

    state.matrix
    |> Enum.count(fn {_, val} ->
      val == @active
    end)
  end

  def solve_2 do
  end

  # PRIVATE
  defp go_cycle(state, 0) do
    state
  end

  defp go_cycle(state, nb) do
    state =
      state
      |> extend_layers()
      |> add_new_layers()

    state.matrix
    |> Enum.reduce(state, fn {coords, val}, updated_state ->
      possible_neighbors = neighbors(coords)

      active_neighbors = active(possible_neighbors, state)

      cond do
        val == @active and (active_neighbors == 2 or active_neighbors == 3) ->
          updated_state

        val == @active ->
          Map.replace(updated_state, :matrix, Map.put(updated_state.matrix, coords, @inactive))

        val == @inactive and active_neighbors == 3 ->
          Map.replace(updated_state, :matrix, Map.put(updated_state.matrix, coords, @active))

        true ->
          Map.put(updated_state, :matrix, Map.put(updated_state.matrix, coords, val))
      end
    end)
    |> go_cycle(nb - 1)
  end

  defp active(possible_neighbors, state) do
    possible_neighbors
    |> Enum.filter(fn coords ->
      case Map.fetch(state.matrix, coords) do
        {:ok, val} ->
          val == @active

        :error ->
          false
      end
    end)
    |> Enum.count()
  end

  defp add_new_layers(state) do
    z = state.max_z + 1

    coords =
      state.matrix
      |> Enum.filter(fn {{_, _, z}, _} ->
        z == 0
      end)

    layer_z1 =
      coords
      |> Enum.reduce(%{}, fn {{x, y, _}, _}, new_matrix ->
        Map.put(new_matrix, {x, y, z}, @inactive)
      end)

    layer_z2 =
      coords
      |> Enum.reduce(%{}, fn {{x, y, _}, _}, new_matrix ->
        Map.put(new_matrix, {x, y, -z}, @inactive)
      end)

    new_matrix = state.matrix |> Map.merge(layer_z1) |> Map.merge(layer_z2)
    Map.replace(state, :matrix, new_matrix) |> Map.replace(:max_z, z)
  end

  def neighbors({x, y, z}) do
    for x <- [-1, 0, 1], y <- [-1, 0, 1], z <- [-1, 0, 1] do
      {x, y, z}
    end
    |> Enum.reject(fn t -> t == {0, 0, 0} end)
    |> Enum.map(fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)
  end

  defp build_initial_matrix_layer(state, filename) do
    initial_matrix =
      filename
      |> get_raw_data()
      |> initiate_coords()

    Map.put(state, :matrix, initial_matrix)
    |> Map.put(:max_z, 0)
  end

  defp initiate_coords(data) do
    data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {ys, xi}, result ->
      ys
      |> Enum.with_index()
      |> Enum.reduce(result, fn {val, y}, acc ->
        Map.put(acc, {xi, y, 0}, val)
      end)
    end)
  end

  defp initialize() do
    {size_x, size_y} = @filename |> get_matrix_size()

    %{}
    |> Map.put(:min_y, 0)
    |> Map.put(:max_y, size_y - 1)
    |> Map.put(:min_x, 0)
    |> Map.put(:max_x, size_x - 1)
    |> build_initial_matrix_layer(@filename)
    |> extend_layers()
  end

  defp extend_layers(state) do
    boundaries_without_corners =
      state.matrix
      |> Enum.filter(fn {{x, y, _}, _} ->
        x == state.min_x or x == state.max_x or y == state.min_y or y == state.max_y
      end)
      |> Enum.reject(fn {{x, y, _}, _} ->
        (x == state.min_x and y == state.min_y) or (x == state.min_x and y == state.max_y) or
          (x == state.max_x and y == state.min_y) or (x == state.max_x and y == state.max_y)
      end)

    corners =
      state.matrix
      |> Enum.filter(fn {{x, y, _}, _} ->
        (x == state.min_x and y == state.min_y) or (x == state.min_x and y == state.max_y) or
          (x == state.max_x and y == state.min_y) or (x == state.max_x and y == state.max_y)
      end)

    new_matrix_boundaries =
      boundaries_without_corners
      |> Enum.reduce(%{}, fn {{x, y, z}, _}, new_matrix ->
        cond do
          x == state.min_x ->
            Map.put(new_matrix, {x - 1, y, z}, @inactive)

          y == state.min_y ->
            Map.put(new_matrix, {x, y - 1, z}, @inactive)

          x == state.max_x ->
            Map.put(new_matrix, {x + 1, y, z}, @inactive)

          y == state.max_y ->
            Map.put(new_matrix, {x, y + 1, z}, @inactive)
        end
      end)

    new_matrix_corners =
      corners
      |> Enum.reduce(%{}, fn {{x, y, z}, _}, new_matrix ->
        cond do
          x == state.min_x and y == state.min_y ->
            Map.put(new_matrix, {x - 1, y - 1, z}, @inactive)
            |> Map.put({x - 1, y, z}, @inactive)
            |> Map.put({x, y - 1, z}, @inactive)

          x == state.max_x and y == state.min_y ->
            Map.put(new_matrix, {x + 1, y - 1, z}, @inactive)
            |> Map.put({x, y - 1, z}, @inactive)
            |> Map.put({x + 1, y, z}, @inactive)

          x == state.max_x and y == state.max_y ->
            Map.put(new_matrix, {x + 1, y + 1, z}, @inactive)
            |> Map.put({x, y + 1, z}, @inactive)
            |> Map.put({x + 1, y, z}, @inactive)

          x == state.min_x and y == state.max_y ->
            Map.put(new_matrix, {x - 1, y + 1, z}, @inactive)
            |> Map.put({x - 1, y, z}, @inactive)
            |> Map.put({x, y + 1, z}, @inactive)
        end
      end)

    extension = Map.merge(new_matrix_boundaries, new_matrix_corners)

    Map.replace(state, :matrix, Map.merge(state.matrix, extension))
    |> Map.replace(:min_x, state.min_x - 1)
    |> Map.replace(:max_x, state.max_x + 1)
    |> Map.replace(:min_y, state.min_y - 1)
    |> Map.replace(:max_y, state.max_y + 1)
  end

  defp get_matrix_size(filename) do
    data =
      filename
      |> get_raw_data()

    size_x =
      data
      |> Enum.count()

    size_y = List.first(data) |> Enum.count()
    {size_x, size_y}
  end

  defp get_raw_data(filename) do
    filename
    |> I.get_lines()
    |> I.decompose_lines()
  end
end
