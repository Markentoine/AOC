defmodule DayThirteen.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    {mn, buses} =
      "thirteen.txt"
      |> get_raw_data()

    at_mn =
      Stream.iterate(mn, &(&1 + 1))
      |> Enum.find(fn m ->
        IO.inspect(m)

        result =
          Enum.reduce(buses, nil, fn b, acc ->
            cond do
              rem(m, b) == 0 ->
                b |> IO.inspect()

              true ->
                acc
            end
          end)

        !is_nil(result)
      end)

    at_mn - mn
  end

  def solve_2 do
    buses =
      "thirteen.txt"
      |> get_buses()
      |> Enum.reject(fn {b, _} -> b == "x" end)
      |> Enum.map(fn {b, i} -> {String.to_integer(b), i} end)

    {first_bus, mn1} = hd(buses)
    {last_bus, mn_final} = List.last(buses)

    Stream.iterate(last_bus, &(&1 + last_bus))
    |> Enum.find(fn nb ->
      first_condition = rem(nb - mn_final, first_bus) == 0

      first_condition && second_condition(buses, nb, mn_final)
    end)
  end

  # PRIVATE
  # DayThirteen.Puzzle.solve_2
  defp second_condition(buses, nb, mn_final) do
    Enum.all?(buses, fn {id, offset} ->
      rem(nb - mn_final + offset, id) == 0
    end)
  end

  defp get_buses(filename) do
    [_, buses] =
      filename
      |> I.get_lines()

    String.split(buses, ",", trim: true) |> Enum.with_index()
  end

  defp get_raw_data(filename) do
    [mn, buses] =
      filename
      |> I.get_lines()

    buses =
      String.split(buses, ",", trim: true)
      |> Enum.reject(&(&1 == "x"))
      |> Enum.map(&String.to_integer/1)

    {String.to_integer(mn), buses}
  end
end
