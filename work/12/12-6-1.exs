defmodule FizzBuzzCase do
  def upto(n) when n > 0 do
    1..n |> Enum.map(&fizzbuzz/1)
  end
  defp fizzbuzz(n) do
    case {rem(n, 3), rem(n, 5) } do
      { 0, 0 } ->
        "FizzBuzz"
      { 0, _ } ->
        "Fizz"
      { _, 0 } ->
        "Buzz"
      { _, _ } ->
        n
    end
  end
end

IO.inspect(FizzBuzzCase.upto(40))
