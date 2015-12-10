defmodule WrappingPaperEstimator do
  def estimate_for_boxes(boxes) do
    boxes
    |> Enum.map(&estimate_for_box/1)
    |> Enum.sum
  end

  def estimate_for_box([l,w,h]) do
    sides = [l * w, w * h, h * l]
    smallest = Enum.min(sides)
    (Enum.map(sides, &( &1 * 2 )) |> Enum.sum) + smallest
  end

  def parse_line(line) do
    line
    |> String.split("x")
    |> Enum.map( fn(numstr) -> {num, ""} = Integer.parse(numstr); num end )
  end
end

defmodule RibbonEstimator do
  def estimate_for_boxes(boxes) do
    boxes
    |> Enum.map(&estimate_for_box/1)
    |> Enum.sum
  end

  def estimate_for_box(dimensions) do
    ribbon_for_wrap = dimensions
                      |> Enum.sort
                      |> Enum.take(2)
                      |> Enum.map(&( &1 * 2 ))
                      |> Enum.sum
    ribbon_for_bow = dimensions
                     |> Enum.reduce(1, fn(acc, side) -> side * acc end)
    ribbon_for_wrap + ribbon_for_bow
  end
end

dimensions = [2,3,4]
IO.puts "estimated square feet for #{inspect dimensions} = #{WrappingPaperEstimator.estimate_for_box(dimensions)}"

boxes = "input.txt"
        |> File.read!
        |> String.strip
        |> String.split("\n")
        |> Enum.map(&WrappingPaperEstimator.parse_line/1)

IO.puts "total estimate: #{WrappingPaperEstimator.estimate_for_boxes(boxes)}"

IO.puts "estimated ribbon for #{inspect dimensions} = #{RibbonEstimator.estimate_for_box(dimensions)}"

IO.puts "total ribbon: #{RibbonEstimator.estimate_for_boxes(boxes)}"
