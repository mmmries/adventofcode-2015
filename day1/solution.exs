defmodule FloorCounter do
  def count(char_list) do
    char_list
    |> Enum.map( fn(?() -> +1
                   (?)) -> -1 end)
    |> Enum.sum
  end
end

defmodule BasementDetector do
  def start_walking_fat_man(-1, _, instruction_number) do
    instruction_number
  end
  def start_walking_fat_man(current_floor, [?(|tail], instruction_number) do
    start_walking_fat_man(current_floor + 1, tail, instruction_number + 1)
  end
  def start_walking_fat_man(current_floor, [?)|tail], instruction_number) do
    start_walking_fat_man(current_floor - 1, tail, instruction_number + 1)
  end
end

char_list = "input.txt"
            |> File.read!
            |> String.to_char_list

IO.puts "Santa ends up on #{FloorCounter.count(char_list)}"
IO.puts "Santa gets to the basement on step #{BasementDetector.start_walking_fat_man(0, char_list, 0)}"
