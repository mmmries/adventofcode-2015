key = "bgvyzdsv"
valid_advent_coin? = fn(num) -> case Base.encode16(:erlang.md5("#{key}#{num}")) do
                                  "00000" <> _rest -> true
                                  _ -> false
                                end
                     end

super_advent_coin? = fn(num) -> case Base.encode16(:erlang.md5("#{key}#{num}")) do
                                  "000000" <> _rest -> true
                                  _ -> false
                                end
                     end

(0..999_999_999) |> Stream.filter(valid_advent_coin?) |> Stream.take(1) |> Enum.to_list |> IO.inspect
(0..999_999_999) |> Stream.filter(super_advent_coin?) |> Stream.take(1) |> Enum.to_list |> IO.inspect
