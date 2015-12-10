defmodule PresentTracker do
  def track_deliveries_for_instructions(instructions), do: track_deliveries_for_instructions({0,0}, instructions, [{0,0}])

  def track_deliveries_for_instructions(_position, [], deliveries), do: Enum.reverse(deliveries)
  def track_deliveries_for_instructions({x,y}, [?^ | tail], deliveries) do
    new_position = {x,y+1}
    track_deliveries_for_instructions(new_position, tail, [new_position | deliveries])
  end
  def track_deliveries_for_instructions({x,y}, [?v | tail], deliveries) do
    new_position = {x,y-1}
    track_deliveries_for_instructions(new_position, tail, [new_position | deliveries])
  end
  def track_deliveries_for_instructions({x,y}, [?> | tail], deliveries) do
    new_position = {x+1,y}
    track_deliveries_for_instructions(new_position, tail, [new_position | deliveries])
  end
  def track_deliveries_for_instructions({x,y}, [?< | tail], deliveries) do
    new_position = {x-1,y}
    track_deliveries_for_instructions(new_position, tail, [new_position | deliveries])
  end
end

instructions = "input.txt"
               |> File.read!
               |> String.strip
               |> String.to_char_list

deliveries = PresentTracker.track_deliveries_for_instructions(instructions)
uniques = deliveries |> Enum.uniq |> Enum.count

IO.puts "unique houses delivered to by santa: #{uniques}"

{santa_instructions, robo_instructions} = instructions
                                          |> Enum.with_index
                                          |> Enum.partition(fn({i,idx}) -> rem(idx,2) == 0 end)
santa_instructions = Enum.map(santa_instructions, fn({i,_idx}) -> i end)
robo_instructions = Enum.map(robo_instructions, fn({i,_idx}) -> i end)

santa_deliveries = PresentTracker.track_deliveries_for_instructions(santa_instructions)
robo_deliveries = PresentTracker.track_deliveries_for_instructions(robo_instructions)
uniques = (santa_deliveries ++ robo_deliveries)
          |> Enum.uniq
          |> Enum.count

IO.puts "unique houses delivered to by santa + robo-santa: #{uniques}"
