defmodule HistorianHysteria do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    input_path
    |> File.stream!()
    |> Stream.map(fn line ->
      line
      |> String.trim()
      |> String.split(~r{\s+}, limit: 2)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip_reduce(0, fn [left, right], sum -> sum + abs(left - right) end)
  end

  def solve_part_2(input_path) do
    {column_1, column_2} =
      input_path
      |> File.stream!()
      |> Stream.map(fn line ->
        line
        |> String.trim()
        |> String.split(~r{\s+}, limit: 2)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.unzip()

    counts = Enum.frequencies(column_2)

    column_1
    |> Enum.map(fn n -> n * Map.get(counts, n, 0) end)
    |> Enum.sum()
  end
end

System.argv()
|> HistorianHysteria.solve()
|> IO.inspect()
