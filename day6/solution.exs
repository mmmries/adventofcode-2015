ExUnit.start

defmodule Grid do
  def new(initial_value, width \\ 1000, height \\ 1000) do
    (0..height) |> Enum.map(fn (_i) ->
      List.duplicate(initial_value, width)
    end)
  end

  def update_grid(grid, constraint, update_fn) do
    grid
    |> Enum.with_index
    |> Enum.map(fn({row, row_number}) ->
      case row_in_constraint?(row_number, constraint) do
        true -> update_row(row, constraint, update_fn)
        false -> row
      end
    end)
  end

  defp update_row(row, constraint, update_fn) do
    row
    |> Enum.with_index
    |> Enum.map(fn({light, column_number}) ->
      case light_in_constraint?(column_number,constraint) do
        true -> update_fn.(light)
        false -> light
      end
    end)
  end

  defp row_in_constraint?(y, {{_lx,ly},{_ux,uy}}) when y >= ly and y <= uy, do: true
  defp row_in_constraint?(_y, _constraint), do: false

  defp light_in_constraint?(x, {{lx,_ly},{ux,_uy}}) when x >= lx and x <= ux, do: true
  defp light_in_constraint?(_x, _constraint), do: false
end

defmodule Instructions do
  @regex ~r/(.*)\s+(\d+),(\d+) through (\d+),(\d+)/

  def run(path, module) do
    instructions = read_instructions(path)
    Enum.reduce(instructions, module.new(1000,1000), fn(instruction, lights) ->
      [_, action, lxs, lys, uxs, uys] = Regex.run(@regex, instruction)
      [lx, ly, ux, uy] = Enum.map([lxs,lys,uxs,uys], &String.to_integer/1)
      case action do
        "turn on" -> module.turn_on(lights, {{lx,ly},{ux,uy}})
        "turn off" -> module.turn_off(lights, {{lx,ly},{ux,uy}})
        "toggle" -> module.toggle(lights, {{lx,ly},{ux,uy}})
      end
    end)
  end

  defp read_instructions(path) do
    path
    |> File.read!
    |> String.strip
    |> String.split("\n")
  end
end

defmodule Lights do
  import Grid
  def new(width \\ 1000, height \\ 1000), do: new(false, width, height)

  def how_many_on?(grid) do
    Enum.reduce(grid, 0, fn(row, acc) ->
      acc + Enum.reduce(row, 0, fn(true, acc) -> acc  + 1
                                  (false, acc) -> acc end)
    end)
  end

  def turn_on(grid, constraint), do: update_grid(grid, constraint, &turn_on_light/1)
  def turn_off(grid, constraint), do: update_grid(grid, constraint, &turn_off_light/1)
  def toggle(grid, constraint), do: update_grid(grid, constraint, &toggle_light/1)

  defp turn_on_light(_), do: true
  defp turn_off_light(_), do: false
  defp toggle_light(light), do: !light
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

defmodule Dimmers do
  import Grid

  def new(width \\ 1000, height \\ 1000), do: new(0, width, height)

  def total_brightness(grid) do
    Enum.reduce(grid, 0, fn(row, acc) ->
      acc + Enum.reduce(row, 0, fn(light, acc) -> acc  + light end)
    end)
  end

  def turn_on(grid, constraint), do: update_grid(grid, constraint, &turn_on_light/1)
  def turn_off(grid, constraint), do: update_grid(grid, constraint, &turn_off_light/1)
  def toggle(grid, constraint), do: update_grid(grid, constraint, &toggle_light/1)

  defp turn_on_light(light), do: light + 1
  defp turn_off_light(0), do: 0
  defp turn_off_light(light), do: light - 1
  defp toggle_light(light), do: light + 2
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

lights = Instructions.run("input.txt", Lights)
IO.puts "there are #{Lights.how_many_on?(lights)} lights on now"

lights = Instructions.run("input.txt", Dimmers)
IO.puts "the total brightness is #{Dimmers.total_brightness(lights)}"
