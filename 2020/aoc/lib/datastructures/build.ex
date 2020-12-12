defmodule Datastructures.Build do
  def get_coords(maxX, maxY, origin \\ 0) do
    for x <- origin..(maxX - 1), y <- origin..(maxY - 1) do
      {x, y}
    end
  end

  def map_coords(values, maxX, maxY, origin \\ 0) do
    get_coords(maxX, maxY, origin)
    |> Enum.zip(values)
    |> Enum.into(%{})
  end
end
