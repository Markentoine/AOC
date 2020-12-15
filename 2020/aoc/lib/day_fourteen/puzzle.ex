defmodule DayFourteen.Puzzle do
  alias Inputs.GetInputs, as: I

  def solve_1 do
    "fourteen.txt"
    |> get_raw_data()
    |> Enum.reduce(%{mask: nil, memory: %{}}, fn instruction, state ->
      process(instruction, state)
    end)
    |> Map.get(:memory)
    |> Map.values()
    |> Enum.sum()
  end

  def solve_2 do
    "fourteen.txt"
    |> get_raw_data()
    |> Enum.reduce(%{mask: nil, memory: %{}}, fn instruction, state ->
      process_2(instruction, state)
    end)
    |> Map.get(:memory)
    |> Map.values()
    |> Enum.sum()
  end

  # PRIVATE
  defp process_2({:mask, mask}, state) do
    %{state | mask: mask}
  end

  defp process_2({:mem, address, value}, state) do
    addresses = masked_addresses(address, state.mask)

    new_memory =
      addresses
      |> Enum.reduce(state.memory, fn ad, map ->
        Map.put(map, ad, value)
      end)

    Map.replace!(state, :memory, new_memory)
  end

  defp masked_addresses(address, mask) do
    address |> convert() |> String.split("", trim: true) |> apply_mask_2(mask)
  end

  defp apply_mask_2(address, mask) do
    x_address =
      Enum.zip(address, mask)
      |> Enum.map(fn {v, m} ->
        cond do
          m == "0" ->
            v

          m == "1" ->
            "1"

          m == "X" ->
            "X"
        end
      end)

    nb_X = x_address |> Enum.filter(fn x -> x == "X" end) |> Enum.count()

    max_num =
      1..nb_X
      |> Enum.map(fn _ -> "1" end)
      |> Enum.join()
      |> String.to_integer(2)

    combinations =
      0..max_num
      |> Enum.map(fn n -> Integer.to_string(n, 2) |> String.pad_leading(nb_X, "0") end)
      |> Enum.map(fn n -> String.split(n, "", trim: true) end)

    x_indexes =
      x_address
      |> Stream.with_index()
      |> Enum.filter(fn {c, _i} -> c == "X" end)
      |> Enum.map(fn {_, i} -> i end)

    combine(combinations, x_indexes, x_address, [])
  end

  defp combine([], _, _, acc) do
    acc |> IO.inspect(label: "comb")
  end

  defp combine([comb | combs], indexes, x_add, acc) do
    address =
      Enum.zip(comb, indexes)
      |> Enum.reduce(x_add, fn {bin, i}, add ->
        add |> List.replace_at(i, bin)
      end)
      |> Enum.join()
      |> String.to_integer(2)

    combine(combs, indexes, x_add, [address | acc])
  end

  defp process({:mask, mask}, state) do
    %{state | mask: mask}
  end

  defp process({:mem, address, value}, state) do
    masked_value = value |> convert() |> apply_mask(state.mask)

    new_memory = state.memory |> Map.put(address, masked_value)
    Map.replace!(state, :memory, new_memory)
  end

  defp apply_mask(bin, mask) do
    Enum.zip(String.split(bin, "", trim: true), mask)
    |> Enum.map(fn {v, m} ->
      cond do
        m == "X" ->
          v

        true ->
          m
      end
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp convert(value) do
    value
    |> Integer.digits(2)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
    |> String.pad_leading(36, "0")
  end

  defp get_raw_data(filename) do
    lines =
      filename
      |> I.get_lines()
      |> Enum.map(fn line ->
        cond do
          line =~ "mask" ->
            mask =
              line
              |> String.split(" ")
              |> List.last()
              |> String.graphemes()

            {:mask, mask}

          line =~ "mem" ->
            [_, address, value] = Regex.run(~r/(\d+)] = (\d+)/, line)
            {:mem, String.to_integer(address), String.to_integer(value)}
        end
      end)
  end
end
