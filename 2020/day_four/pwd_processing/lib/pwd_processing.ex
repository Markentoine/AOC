defmodule PwdProcessing do
  def solve_4_1 do
    "passports.txt"
    |> get_passports()
    |> filter_valid_passports()
    |> Enum.count()
  end

  def solve_4_2 do
    "passports.txt"
    |> get_passports()
    |> filter_valid_passports()
    |> check_fields()
    |> Enum.count()
  end

  # PRIVATE
  defp check_fields(passports) do
    passports
    |> Stream.reject(&check_birth_year/1)
    |> Stream.reject(&check_issue_year/1)
    |> Stream.reject(&check_expiration_year/1)
    |> Stream.reject(&check_height/1)
    |> Stream.reject(&check_hair_color/1)
    |> Stream.reject(&check_eye_color/1)
    |> Stream.reject(&check_pid/1)
  end

  defp check_pid(passport) do
    not Regex.match?(~r/^[0-9]{9}$/, passport.pid)
  end

  defp check_eye_color(passport) do
    not (~w(amb blu brn gry grn hzl oth) |> Enum.member?(passport.ecl))
  end

  defp check_hair_color(passport) do
    not Regex.match?(~r/^#[0-9a-f]{6}$/, passport.hcl)
  end

  defp check_height(passport) do
    cond do
      Regex.match?(~r/^[0-9]{3}cm/, passport.hgt) ->
        [cm] = passport.hgt |> String.split(~r/cm/, trim: true)
        cm = cm |> String.to_integer()
        not (cm >= 150 and cm <= 193)

      Regex.match?(~r/^[0-9]{2}in/, passport.hgt) ->
        [inc] = passport.hgt |> String.split(~r/in/, trim: true)
        inc = inc |> String.to_integer()
        not (inc >= 59 and inc <= 76)

      true ->
        true
    end
  end

  defp check_birth_year(passport) do
    {byr, _} = passport.byr |> Integer.parse()
    not (byr in 1920..2002)
  end

  defp check_issue_year(passport) do
    iyr = passport.iyr |> String.to_integer()
    not (is_integer(iyr) and (iyr >= 2010 and iyr <= 2020))
  end

  defp check_expiration_year(passport) do
    eyr = passport.eyr |> String.to_integer()
    not (is_integer(eyr) and eyr >= 2020 and eyr <= 2030)
  end

  defp filter_valid_passports(passports) do
    passports
    |> Enum.filter(fn passport ->
      [:hgt, :iyr, :eyr, :hcl, :pid, :ecl, :byr]
      |> Enum.all?(fn key -> Map.fetch!(passport, key) != nil end)
    end)
  end

  defp build_passports_files(raw) do
    raw
    |> Enum.reduce(fn line, acc ->
      cond do
        line == "" ->
          acc <> "@@@"

        true ->
          acc <> "//" <> line
      end
    end)
    |> String.split("@@@")
    |> Stream.map(&replace_/1)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&split_on_space/1)
    |> Stream.map(&build_passport/1)
    |> Enum.map(& &1)
  end

  defp replace_(str), do: str |> String.replace("//", " ")

  defp split_on_space(str), do: str |> String.split(" ")

  defp build_passport(infos) do
    infos
    |> Enum.reduce(Passport.new(), fn info, passport ->
      [key, value] = info |> String.split(":", trim: true)
      key = String.to_atom(key)
      passport |> Map.replace(key, value)
    end)
  end

  defp get_passports(filename) do
    filename
    |> get_inputs()
    |> build_passports_files()
  end

  defp get_inputs(filename) do
    filename
    |> get_path()
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
  end

  defp get_path(filename) do
    filename
    |> Path.expand(__DIR__)
  end
end
