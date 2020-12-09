defmodule DaySeven.Challenge do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    raw_data = extract_data("seven.txt")
    data  = raw_data |> build_data()
    data
    |> find_possible_containers(:shiny_gold, data, [])
    |> Enum.uniq()
    |> Enum.count()
  end

  def solve_2 do
    raw_data = extract_data("seven.txt")
    data  = raw_data |> build_data()
    data
    |> count_total_numbers_bags(:shiny_gold, 0)
  end

  # PRIVATE

  defp count_total_numbers_bags(data, bag, counter) do
    bags_contained = data |> Enum.into(%{}) |> Map.fetch!(bag)
    # [dark_orange: 3, dark_red: 2]
    cond do
      Enum.empty?(bags_contained) ->
        counter
      true ->
        counter = counter + Enum.reduce(bags_contained, 0, fn {_, n}, total -> total + n end)
        bags_contained
        |> Enum.reduce(counter, fn {ba, nb}, sum -> sum + nb * count_total_numbers_bags(data, ba, 0) end)
    end
  end

  defp find_possible_containers([], _, _, list_possible_bags), do: list_possible_bags

  defp find_possible_containers([{current_bag, contain} | rest], bag, full_data, list_possible_bags) do
    cond do
      contains?(contain, bag) ->
        find_possible_containers(rest, bag, full_data, [current_bag | list_possible_bags]) ++ find_possible_containers(full_data, current_bag, full_data, [])
      true ->
        find_possible_containers(rest, bag, full_data, list_possible_bags)
    end
  end

  def contains?(contain, bag) do
    contain |> Enum.any?(fn {n, _nb} -> n == bag end)
  end

  defp extract_data(filename) do
    filename
    |> I.get_lines()
    |> Enum.map(fn l -> l |> String.split("contain", trim: true) end)
  end

  defp build_data(list), do: Enum.zip(get_keys(list), get_values(list))

  defp get_keys(list) do
    list
    |> Enum.reduce([], fn [bag, _], bags ->
      [color1, color2, _] = String.split(bag, " ", trim: true)
      [String.to_atom(color1 <> "_" <> color2) | bags]
    end)
  end

  defp get_values(list) do
    list
    |> Enum.reduce([], fn [_, contain], conts ->
      containees = String.split(contain, ",", trim: true)

      new =
        Enum.reduce(containees, [], fn c, acc ->
          cond do
            Regex.match?(~r/no/, c) ->
              acc

            true ->
              [nb, color1, color2, _] = String.split(c, " ", trim: true)
              {nb, _} = Integer.parse(nb)
              [{String.to_atom(color1 <> "_" <> color2), nb} | acc]
          end
        end)

      [new | conts]
    end)
  end
end

#
#[
#  dotted_black: [],
#  faded_blue: [],
#  vibrant_plum: [dotted_black: 6, faded_blue: 5],
#  dark_olive: [dotted_black: 4, faded_blue: 3],
#  shiny_gold: [vibrant_plum: 2, dark_olive: 1],
#  muted_yellow: [faded_blue: 9, shiny_gold: 2],
#  bright_white: [shiny_gold: 1],
#  dark_orange: [muted_yellow: 4, bright_white: 3],
#  light_red: [muted_yellow: 2, bright_white: 1]
#]
