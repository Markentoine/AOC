defmodule DayFifteen.Puzzle do
  alias Inputs.GetInputs, as: I
  alias DayFifteen.Fif

  def solve_1 do
    "fifteen.txt"
    |> get_raw_data()
    |> initiate_game([], 0)
    |> run_game()
  end

  def solve_2 do
    "fifteen_test.txt"
    |> get_raw_data()
    |> initiate_game([], 0)
    |> run_game_2()
  end

  def solve do
    "fifteen.txt"
    |> get_raw_data()
    |> start(Fif.new(), 0)
    |> run()
  end

  # PRIVATE
  # 29999999
  defp run({state, 30_000_000}) do
    state.last
  end

  defp run({state, counter}) do
    {n, c} = state.last
    retrieved_value = Map.fetch(state.memory, n)

    case retrieved_value do
      :error ->
        new_memory = Map.put(state.memory, n, c)
        new_last = {"0", counter}

        new_state =
          Map.put(state, :memory, new_memory)
          |> Map.put(:last, new_last)

        run({new_state, counter + 1})

      {:ok, val} ->
        age = c - val
        new_memory = Map.put(state.memory, n, c)
        new_last = {Integer.to_string(age), counter}

        new_state = Map.put(state, :memory, new_memory) |> Map.put(:last, new_last)

        run({new_state, counter + 1})
    end
  end

  defp start([], state, counter) do
    {state, counter}
  end

  defp start([el | []], state, counter) do
    new_state = Map.put(state, :last, {el, counter})
    start([], new_state, counter + 1)
  end

  defp start([last | []], state, counter) do
    new_memory = Map.put(state.memory, last, [counter])
    new_last = {last, counter}
    new_state = Map.put(state, :memory, new_memory) |> Map.put(:last, new_last)

    start([], new_state, counter)
  end

  defp start([nb | tail], state, counter) do
    new_memory = Map.put(state.memory, nb, counter)
    new_state = Map.put(state, :memory, new_memory)
    start(tail, new_state, counter + 1)
  end

  defp run_game_2({[{nb, 2019} | _], _}) do
    nb
  end

  defp run_game_2({[{spoken_nb, idx} = current | rest] = list, counter}) do
    {already_spoken, new_memory} = already_spoken_2?(rest, spoken_nb, nil, [])
    new_memory = Enum.reverse(new_memory)

    cond do
      already_spoken ->
        {_, c} = already_spoken
        new_number = idx - c

        run_game_2(
          {[{Integer.to_string(new_number), counter} | [current | new_memory]], counter + 1}
        )

      true ->
        run_game_2({[{"0", counter} | list], counter + 1})
    end
  end

  defp already_spoken_2?([], _, found, new_memory) do
    {found, new_memory}
  end

  defp already_spoken_2?([{n, _i} = found | rest] = memory, nb, nil, new_memory)
       when nb == n do
    new_rest = Enum.reverse(rest)
    {found, new_rest ++ new_memory}
  end

  defp already_spoken_2?([el | rest], nb, found, new_memory) do
    already_spoken_2?(rest, nb, found, [el | new_memory])
  end

  defp run_game({[{nb, 2019} | _], _}) do
    nb
  end

  defp run_game({[{spoken_nb, idx} | rest] = list, counter}) do
    already_spoken = already_spoken?(spoken_nb, rest)

    cond do
      already_spoken ->
        {_, c} = already_spoken
        new_number = idx - c
        run_game({[{Integer.to_string(new_number), counter} | list], counter + 1})

      true ->
        run_game({[{"0", counter} | list], counter + 1})
    end
  end

  defp already_spoken?(nb, memory) do
    Enum.find(memory, fn {n, i} -> n == nb end)
  end

  defp initiate_game([], list, counter) do
    {list, counter}
  end

  defp initiate_game([nb | rest], list, counter) do
    initiate_game(rest, [{nb, counter} | list], counter + 1)
  end

  defp get_raw_data(filename) do
    filename
    |> I.read_lines()
    |> I.split_line(",")
  end
end
