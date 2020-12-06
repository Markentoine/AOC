defmodule Inputs.GetInputs do
  def get_lines(filename) do
    filename
    |> read_lines()
    |> String.split("\n")
  end

  def get_group_lines(filename) do
    filename
    |> read_lines()
    |> String.split("\n\n")
  end

  def get_chars(filename) do
    filename
    |> read_lines()
    |> String.split("", trim: true)
  end

  def split_line(line, boundary) do
    line |> String.split(boundary)
  end

  # PRIVATE

  defp read_lines(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
