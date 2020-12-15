defmodule DayTwelve.Boat do
  defstruct E: 0, W: 0, N: 0, S: 0, dir: :E

  def new() do
    __struct__
  end
end
