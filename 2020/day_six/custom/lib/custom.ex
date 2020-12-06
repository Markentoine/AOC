defmodule Custom do
  def solve_6_1 do
    "answers.txt"
    |> get_groups_answers()
    |> Stream.map(fn group ->
      group
      |> Enum.map(fn str ->
        String.split(str, "", trim: true)
      end)
    end)
    |> Stream.map(fn group -> group |> List.flatten() |> Enum.uniq() end)
    |> Stream.map(fn group -> group |> Enum.count() end)
    |> Enum.sum()
  end

  def solve_6_2 do
    "answers.txt"
    |> get_groups_answers()
    |> Stream.map(fn group ->
      group
      |> Enum.map(fn str ->
        String.split(str, "", trim: true)
      end)
    end)
    |> sum_common_values()
  end

  # PRIVATE

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

  defp count_common_elements([first | others] = group, counter) do
    current_count =
      first
      |> Enum.reduce(0, fn el, acc ->
        presence = others |> Enum.all?(fn o -> Enum.member?(o, el) end)

        cond do
          presence ->
            acc + 1

          true ->
            acc
        end
      end)

    counter + current_count
  end

  defp build_answers_files(raw) do
    raw
    |> Enum.reduce(fn line, acc ->
      cond do
        line == "" ->
          acc <> "@@@"

        true ->
          acc <> "//" <> line
      end
    end)
    |> String.split("@@@")
    |> Stream.map(&replace_/1)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&split_on_space/1)
    |> Enum.map(& &1)
  end

  defp replace_(str), do: str |> String.replace("//", " ")

  defp split_on_space(str), do: str |> String.split(" ")

  defp get_groups_answers(filename) do
    filename
    |> get_inputs()
    |> build_answers_files()
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
