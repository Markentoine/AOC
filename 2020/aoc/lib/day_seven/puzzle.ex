defmodule DaySeven.Challenge do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    raw_data = extract_data("seven_test.txt")
    raw_data |> build_data()
  end

  def solve_2 do
  end

  # PRIVATE

  defp extract_data(filename) do
    filename
    |> I.get_lines()
    |> Enum.map(fn l -> l |> String.split("contain", trim: true) end)
  end

  defp build_data(list) do
    keys = get_keys(list)
    values = get_values(list)
  end

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
              [[String.to_atom(color1 <> "_" <> color2), nb] | acc]
          end
        end)

      [new | conts]
    end)
  end
end
