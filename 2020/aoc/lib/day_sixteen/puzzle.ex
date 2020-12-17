defmodule DaySixteen.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    data =
      "sixteen.txt"
      |> get_data()

    all_ranges = Map.values(data.fields) |> Enum.flat_map(& &1)

    all_invalids =
      Enum.reduce(data.nearby_tickets, [], fn nbt, invalids ->
        current_inv =
          nbt
          |> String.split(",", trim: true)
          |> Enum.reduce([], fn n, list ->
            cond do
              Enum.member?(all_ranges, String.to_integer(n)) ->
                list

              true ->
                [String.to_integer(n) | list]
            end
          end)

        current_inv ++ invalids
      end)

    Enum.sum(all_invalids)
  end

  def solve_2 do
  end

  # PRIVATE

  defp get_data(filename) do
    [fields, ticket, nearby_tickets] =
      filename
      |> I.get_group_lines()

    fields_lines =
      fields
      |> String.split("\n", trim: true)
      |> Enum.map(fn l -> String.split(l, ":", trim: true) end)
      |> Enum.reduce(%{}, fn [field_name, ranges], acc ->
        ranges = Regex.scan(~r/(\d+)-(\d+)/, ranges)

        full_ranges =
          ranges
          |> Enum.reduce([], fn info, list ->
            [_, from, to] = info
            Enum.to_list(String.to_integer(from)..String.to_integer(to)) ++ list
          end)

        Map.put(acc, field_name, full_ranges)
      end)

    [_, ticket] = String.split(ticket, "\n", trim: true)

    [_ | nearby_tickets] = nearby_tickets |> String.split("\n", trim: true)

    %{fields: fields_lines, ticket: ticket, nearby_tickets: nearby_tickets}
  end
end
