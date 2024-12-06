defmodule RedNosedReports do
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
    |> stream_reports()
    |> Enum.count(fn report ->
      safe?(report)
    end)
  end

  def solve_part_2(input_path) do
    input_path
    |> stream_reports()
    |> Enum.count(fn report ->
      safe?(report) or
        Enum.any?(0..(length(report) - 1), fn i ->
          report |> List.delete_at(i) |> safe?()
        end)
    end)
  end

  def stream_reports(input_path) do
    input_path
    |> File.stream!()
    |> Stream.map(fn line ->
      line
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def safe?(report) do
    changes =
      report
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [left, right] -> right - left end)

    Enum.all?(changes, fn c -> c in [1, 2, 3] end) or
      Enum.all?(changes, fn c -> c in [-1, -2, -3] end)
  end
end

System.argv()
|> RedNosedReports.solve()
|> IO.inspect()
