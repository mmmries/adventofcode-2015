ExUnit.start

defmodule Lights do
  def new(width \\ 1000, height \\ 1000) do
    (0..height) |> Enum.map(fn (_i) ->
      List.duplicate(false, width)
    end)
  end

  def how_many_on?(grid) do
    Enum.reduce(grid, 0, fn(row, acc) ->
      acc + Enum.reduce(row, 0, fn(true, acc) -> acc  + 1
                                  (false, acc) -> acc end)
    end)
  end

  def turn_on(grid, constraint), do: update_grid(grid, constraint, :on)
  def turn_off(grid, constraint), do: update_grid(grid, constraint, :off)
  def toggle(grid, constraint), do: update_grid(grid, constraint, :toggle)

  defp update_grid(grid, constraint, action) do
    grid
    |> Enum.with_index
    |> Enum.map(&( turn_on_row(&1, constraint, action) ))
  end

  defp turn_on_row({row, row_number}, constraint, action) do
    row
    |> Enum.with_index
    |> Enum.map(fn({light, column_number}) ->
      case in_constraint?({row_number,column_number},constraint) do
        true -> update_light(light, action)
        false -> light
      end
    end)
  end

  defp in_constraint?({x,y}, {{lx,ly},{ux,uy}}) when x >= lx and x <= ux and y >= ly and y <= uy, do: true
  defp in_constraint?(_coords, _constraint), do: false

  defp update_light(_, :on), do: true
  defp update_light(_, :off), do: false
  defp update_light(light, :toggle), do: !light
end

defmodule LightsTest do
  use ExUnit.Case
  import Lights

  test "it starts with everything off" do
    lights = new
    assert how_many_on?(lights) == 0
  end

  test "it can turn on some lights" do
    lights = new(5,5) |> turn_on({{0,0}, {2,2}})
    assert how_many_on?(lights) == 9
  end

  test "it can turn off some lights" do
    lights = new(5,5) |> turn_on({{0,0}, {2,2}}) |> turn_off({{0,0},{1,1}})
    assert how_many_on?(lights) == 5
  end

  test "it can toggle some lights" do
    lights = new(5,5) |> turn_on({{0,0}, {2,2}}) |> toggle({{2,0},{3,2}})
    assert how_many_on?(lights) == 9
  end
end

instructions = "input.txt"
               |> File.read!
               |> String.strip
               |> String.split("\n")
regex = ~r/(.*)\s+(\d+),(\d+) through (\d+),(\d+)/
#lights = Enum.reduce(instructions, Lights.new(1000,1000), fn(instruction, lights) ->
#  [_, action, lxs, lys, uxs, uys] = Regex.run(regex, instruction)
#  [lx, ly, ux, uy] = Enum.map([lxs,lys,uxs,uys], &String.to_integer/1)
#  case action do
#    "turn on" -> Lights.turn_on(lights, {{lx,ly},{ux,uy}})
#    "turn off" -> Lights.turn_off(lights, {{lx,ly},{ux,uy}})
#    "toggle" -> Lights.toggle(lights, {{lx,ly},{ux,uy}})
#  end
#end)

#IO.puts "there are #{Lights.how_many_on?(lights)} lights on now"

defmodule Dimmers do
  def new(width \\ 1000, height \\ 1000) do
    (0..height) |> Enum.map(fn (_i) ->
      List.duplicate(0, width)
    end)
  end

  def total_brightness(grid) do
    Enum.reduce(grid, 0, fn(row, acc) ->
      acc + Enum.reduce(row, 0, fn(light, acc) -> acc  + light end)
    end)
  end

  def turn_on(grid, constraint), do: update_grid(grid, constraint, :on)
  def turn_off(grid, constraint), do: update_grid(grid, constraint, :off)
  def toggle(grid, constraint), do: update_grid(grid, constraint, :toggle)

  defp update_grid(grid, constraint, action) do
    grid
    |> Enum.with_index
    |> Enum.map(&( turn_on_row(&1, constraint, action) ))
  end

  defp turn_on_row({row, row_number}, constraint, action) do
    row
    |> Enum.with_index
    |> Enum.map(fn({light, column_number}) ->
      case in_constraint?({row_number,column_number},constraint) do
        true -> update_light(light, action)
        false -> light
      end
    end)
  end

  defp in_constraint?({x,y}, {{lx,ly},{ux,uy}}) when x >= lx and x <= ux and y >= ly and y <= uy, do: true
  defp in_constraint?(_coords, _constraint), do: false

  defp update_light(light, :on), do: light + 1
  defp update_light(0, :off), do: 0
  defp update_light(light, :off), do: light - 1
  defp update_light(light, :toggle), do: light + 2
end

defmodule DimmersTest do
  use ExUnit.Case
  import Dimmers

  test "stars dark" do
    lights = new(5,5)
    assert total_brightness(lights) == 0
  end

  test "can turn on lights" do
    lights = new(5,5) |> turn_on({{0,0},{2,2}})
    assert total_brightness(lights) == 9
  end

  test "can make them brighter" do
    lights = new(5,5) |> turn_on({{0,0},{2,2}}) |> turn_on({{0,0},{2,2}})
    assert total_brightness(lights) == 18
  end

  test "toggling makes things bright faster" do
    lights = new(5,5) |> toggle({{0,0},{2,2}})
    assert total_brightness(lights) == 18
  end

  test "cannot be negative" do
    lights = new(5,5) |> turn_off({{0,0},{2,2}})
    assert total_brightness(lights) == 0
  end
end

lights = Enum.reduce(instructions, Dimmers.new(1000,1000), fn(instruction, lights) ->
  [_, action, lxs, lys, uxs, uys] = Regex.run(regex, instruction)
  [lx, ly, ux, uy] = Enum.map([lxs,lys,uxs,uys], &String.to_integer/1)
  case action do
    "turn on" -> Dimmers.turn_on(lights, {{lx,ly},{ux,uy}})
    "turn off" -> Dimmers.turn_off(lights, {{lx,ly},{ux,uy}})
    "toggle" -> Dimmers.toggle(lights, {{lx,ly},{ux,uy}})
  end
end)

IO.puts "the total brightness is #{Dimmers.total_brightness(lights)}"
