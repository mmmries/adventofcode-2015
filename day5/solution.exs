ExUnit.start

defmodule Niceness do
  def nice?(str) do
    three_vowels?(str) && no_naughty_combos?(str) && repeated_letter?(str)
  end

  defp three_vowels?(string) do
    (String.replace(string, ~r([^aeiou]), "") |> String.length) >= 3
  end

  defp no_naughty_combos?(str) do
    !(String.contains?(str, "ab") || String.contains?(str, "cd") || String.contains?(str, "pq") || String.contains?(str, "xy"))
  end

  defp repeated_letter?(str) do
    repeated_letter?(nil, String.to_char_list(str))
  end
  defp repeated_letter?(_, []), do: false
  defp repeated_letter?(previous, [previous | _tail]), do: true
  defp repeated_letter?(_previous, [next | tail]), do: repeated_letter?(next, tail)

  def really_nice?(str) do
    at_least_one_sandwich?(str) && pair_occuring_twice?(str)
  end

  def at_least_one_sandwich?(str) do
    num_sandwiches = str
                    |> String.to_char_list
                    |> Enum.chunk(3, 1)
                    |> Enum.filter(fn([a, _, a]) -> true
                                     (_) -> false end)
                    |> Enum.count
    num_sandwiches >= 1
  end

  def pair_occuring_twice?(str) do
    str
    |> pairs_with_indices
    |> recurring_pair?
  end

  defp pairs_with_indices(str) do
    str |> String.to_char_list |> Enum.chunk(2,1) |> Enum.with_index
  end

  defp recurring_pair?([]), do: false
  defp recurring_pair?([{pair, idx} | tail]) do
    case Enum.filter(tail, fn({c, cidx}) -> c == pair && cidx > (idx + 1) end) do
      [] -> recurring_pair?(tail)
      _ -> true
    end
  end
end

defmodule NicenessTest do
  use ExUnit.Case
  import Niceness

  test "knows nice strings" do
    assert nice?("ugknbfddgicrmopn") == true
    assert nice?("aaa") == true
  end

  test "knows naughty strings" do
    assert nice?("jchzalrnumimnmhp") == false
    assert nice?("haegwjzuvuyypxyu") == false
    assert nice?("dvszwmarrgswjxmb") == false
    assert really_nice?("aaaa") == true
  end

  test "knows really nice strings" do
    assert really_nice?("qjhvhtzxzqqjkmpb") == true
    assert really_nice?("xxyxx") == true
  end

  test "knows really naughty strings" do
    assert really_nice?("uurcxstgmygtbstg") == false
    assert really_nice?("ieodomkazucvgmuy") == false
    assert really_nice?("aaa") == false
  end
end

strings = "input.txt"
          |> File.read!
          |> String.strip
          |> String.split("\n")

number_easy_nice = strings
                   |> Enum.filter(&Niceness.nice?/1)
                   |> Enum.count

IO.puts "There were #{number_easy_nice} nice strings (with easy rules)"

number_really_nice = strings
                     |> Enum.filter(&Niceness.really_nice?/1)
                     |> Enum.count

IO.puts "There were #{number_really_nice} really nice strings (with hard rules)"
