defmodule DayEight.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    {data, _} = extract_data("eight.txt")
    max_index = data |> Enum.count()
    data |> run(0, false, 0, max_index, data, [])
  end

  def solve_2 do
    {data, _} = extract_data("eight.txt")
    max_index = data |> Enum.count()
    data |> run(0, false, 0, max_index, data, possible_corrupted_keys(data))
  end

  # PRIVATE
  defp run(_, acc, true, _, _, _, []) do
    acc
  end

  defp run(_, _, true, _, max_index, original_program, [key | rest]) do
    key
    |> correct(original_program)
    |> run(0, false, 0, max_index, original_program, rest)
  end

  defp run(program, acc, _repeat?, index, max_index, original_program, keys) do
    cond do
      index == max_index ->
        acc

      true ->
        {ins, arg, seen} = Map.fetch!(program, index)
        read_instruction({ins, arg, seen}, program, acc, index, max_index, original_program, keys)
    end
  end

  defp possible_corrupted_keys(program) do
    program
    |> Map.keys()
    |> Enum.filter(fn k ->
      value = Map.fetch!(program, k)

      case value do
        {"nop", _, _} ->
          true

        {"jmp", _, _} ->
          true

        _ ->
          false
      end
    end)
  end

  defp correct(key, original_program) do
    new_instruction = original_program[key] |> switch_ins()

    original_program
    |> Map.replace!(key, new_instruction)
    |> IO.inspect(label: "program")
    |> reset()
  end

  def switch_ins({ins, arg, _}) do
    case ins do
      "nop" ->
        {"jmp", arg, false}

      "jmp" ->
        {"nop", arg, false}
    end
  end

  defp reset(program) do
    program
    |> Enum.reduce(%{}, fn {key, {ins, arg, _}}, new_map ->
      Map.put(new_map, key, {ins, arg, false})
    end)
  end

  defp read_instruction({ins, arg, seen}, program, acc, index, max_index, original_program, keys) do
    cond do
      seen ->
        run(program, acc, true, index, max_index, original_program, keys)

      true ->
        updated_program = Map.replace!(program, index, {ins, arg, true})

        case ins do
          "nop" ->
            run(updated_program, acc, false, index + 1, max_index, original_program, keys)

          "jmp" ->
            run(updated_program, acc, false, index + arg, max_index, original_program, keys)

          "acc" ->
            run(updated_program, acc + arg, false, index + 1, max_index, original_program, keys)
        end
    end
  end

  defp sanitize_argument(arg) do
    {arg, _} = Integer.parse(arg)
    arg
  end

  defp extract_data(filename) do
    filename
    |> I.get_lines()
    |> Enum.reduce({%{}, 0}, fn l, {map, pos} ->
      [ins, arg] = l |> String.split(" ", trim: true)
      map = Map.put(map, pos, {ins, sanitize_argument(arg), false})
      {map, pos + 1}
    end)
  end
end
