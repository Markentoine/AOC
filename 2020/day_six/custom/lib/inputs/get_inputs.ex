defmodule Inputs.GetInputs do
  def get_lines(filename) do
    filename
    |> read_lines()
    |> String.trim()
    |> String.split("\n")
  end

  def get_group_lines(filename) do
    filename
    |> read_lines()
    |> String.trim()
    |> String.split("\n\n")
  end

  def split_line(line, boundary) do
    line |> String.split(boundary)
  end

  # PRIVATE

  defp read_lines(filename) do
    filename
    |> get_path()
    |> File.read!()
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
