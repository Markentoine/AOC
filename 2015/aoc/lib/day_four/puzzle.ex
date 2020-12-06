defmodule DayFour.Puzzle do
  alias Inputs.GetInputs, as: I

  @key "ckczppom"
  @keytest "abcdef"
  def solve_1 do
    find_number(0)
  end

  # PRIVATE

  defp find_number(n) do
    hash = n |> Integer.to_string() |> crypto()

    cond do
      Regex.match?(~r/^0{6}/, hash) ->
        n

      true ->
        find_number(n + 1)
    end
  end

  defp crypto(number) do
    :crypto.hash(:md5, @key <> number) |> Base.encode16()
  end
end
