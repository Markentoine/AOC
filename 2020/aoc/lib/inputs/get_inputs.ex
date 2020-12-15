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

  def decompose_lines(lines) do
    lines |> Enum.map(&get_chars/1)
  end

  def get_chars(line) do
    line |> split_line("")
  end

  def split_line(line, boundary) do
    line |> String.split(boundary, trim: true)
  end

  # PRIVATE

  def read_lines(filename) do
    filename
    |> get_path()
    |> File.read!()
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
