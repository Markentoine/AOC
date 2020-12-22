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
    data =
      "sixteen.txt"
      |> get_data()

    all_ranges = Map.values(data.fields) |> Enum.flat_map(& &1)

    valid_tickets =
      discard_invalids(data.nearby_tickets, all_ranges)
      |> Enum.map(fn t ->
        String.split(t, ",", trim: true)
        |> Stream.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
      end)

    # updated_data = Map.replace!(data, :nearby_tickets, valid_tickets)

    transpositions =
      case [data.ticket | valid_tickets] do
        [ticket | []] ->
          ticket

        _ ->
          transpose([data.ticket | valid_tickets])
      end

    possible_fields_indexed =
      Enum.map(transpositions, fn tr ->
        Enum.filter(data.fields, fn {_field, range} ->
          Enum.all?(tr, fn el ->
            Enum.member?(range, el)
          end)
        end)
      end)
      |> Enum.map(fn l ->
        Enum.map(l, fn {field_name, _range} ->
          field_name
        end)
      end)
      |> Enum.with_index()
      |> find_matching_field([])
      |> compute_final_result(data.ticket)
  end

  # PRIVATE
  defp compute_final_result(sorted_fields, ticket) do
    sorted_fields
    |> Enum.reduce([], fn {name, idx}, acc ->
      cond do
        name =~ "departure" ->
          [idx | acc]

        true ->
          acc
      end
    end)
    |> Enum.reduce(1, fn idx, acc ->
      Enum.fetch!(ticket, idx) * acc
    end)
  end

  defp find_matching_field([], result) do
    result |> Enum.sort_by(fn {_, idx} -> idx end)
  end

  defp find_matching_field(fields, result) do
    complex_field? =
      fields
      |> Enum.any?(fn {possible_fields, _} ->
        Enum.count(possible_fields) >= 2
      end)

    cond do
      complex_field? ->
        uniq_field =
          Enum.find(fields, fn {possible_fields, _} ->
            Enum.count(possible_fields) == 1
          end)

        {[uniq_field_name], idx} = uniq_field

        new_result = [{uniq_field_name, idx} | result]

        new_fields =
          fields
          |> Enum.map(fn {possible_fields, index} ->
            {Enum.reject(possible_fields, fn field_name ->
               field_name == uniq_field_name
             end), index}
          end)
          |> Enum.reject(fn {l, _} -> l == [] end)

        find_matching_field(new_fields, new_result)

      true ->
        uniq_field =
          Enum.find(fields, fn {possible_fields, _} ->
            Enum.count(possible_fields) == 1
          end)

        {[uniq_field_name], idx} = uniq_field

        new_result = [{uniq_field_name, idx} | result]
        find_matching_field([], new_result)
    end
  end

  defp transpose([first | _] = lists) do
    len = Enum.count(first)
    slots = 1..len |> Enum.map(fn _ -> [] end)
    break(slots, lists)
  end

  defp break(slots, []) do
    slots
  end

  defp break(slots, [list | lists]) do
    Enum.zip(list, slots) |> Enum.map(fn {n, l} -> [n | l] end) |> break(lists)
  end

  defp discard_invalids(tickets, range) do
    tickets
    |> Enum.filter(fn nbt ->
      nbt
      |> String.split(",", trim: true)
      |> Enum.all?(fn n ->
        Enum.member?(range, String.to_integer(String.trim(n)))
      end)
    end)
  end

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

    ticket =
      ticket
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    [_ | nearby_tickets] = nearby_tickets |> String.split("\n", trim: true)

    %{fields: fields_lines, ticket: ticket, nearby_tickets: nearby_tickets}
  end
end
