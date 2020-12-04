defmodule Passport do
  defstruct hgt: nil, iyr: nil, eyr: nil, hcl: nil, cid: nil, pid: nil, ecl: nil, byr: nil

  def new do
    __struct__
  end
end
