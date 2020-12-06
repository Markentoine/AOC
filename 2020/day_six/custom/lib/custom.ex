defmodule Custom do
  alias Inputs.GetInputs, as: Inputs

  def solve_6_1 do
    extract_inputs("answers.txt")
    |> Stream.map(fn group ->
      group
      |> Enum.map(fn str ->
        String.split(str, "", trim: true)
      end)
    end)
    |> Stream.map(&List.flatten/1)
    |> Stream.map(&Enum.uniq/1)
    |> Stream.map(&Enum.count/1)
    |> Enum.sum()
  end

  def solve_6_2 do
    extract_inputs("answers.txt")
    |> Stream.map(fn group ->
      group
      |> Enum.map(fn str ->
        String.split(str, "", trim: true)
      end)
    end)
    |> sum_common_values()
  end

  # PRIVATE
  defp extract_inputs(filename) do
    filename
    |> Inputs.get_group_lines()
    |> Stream.map(fn l -> Inputs.split_line(l, "\n") end)
  end

  defp sum_common_values(list_of_groups) do
    list_of_groups
    |> Stream.map(fn group ->
      group |> Enum.sort_by(&Enum.count/1)
    end)
    |> Enum.reduce(0, &count_common_elements/2)
  end

  defp count_common_elements([first | []], counter) do
    counter + Enum.count(first)
  end

  defp count_common_elements([first | others], counter) do
    current_count =
      first
      |> Enum.reduce(0, fn el, acc ->
        presence = others |> Enum.all?(fn o -> Enum.member?(o, el) end)
        presence |> _?(acc + 1, acc)
      end)

    counter + current_count
  end

  defp _?(predicate, prop1, prop2) do
    cond do
      predicate ->
        prop1

      true ->
        prop2
    end
  end
end
