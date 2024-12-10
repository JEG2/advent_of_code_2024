defmodule MullItOver do
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
    |> File.read!()
    |> then(&Regex.scan(~r{mul\((\d+),(\d+)\)}, &1, capture: :all_but_first))
    |> Enum.map(fn nums ->
      nums |> Enum.map(&String.to_integer/1) |> Enum.product()
    end)
    |> Enum.sum()
  end

  def solve_part_2(input_path) do
    input_path
    |> File.read!()
    |> then(&Regex.scan(~r{(?:mul\((\d+),(\d+)\)|do\(\)|don't\(\))}, &1))
    |> Enum.reduce({:enabled, 0}, fn
      ["do()"], {_mode, total} ->
        {:enabled, total}

      ["don't()"], {_mode, total} ->
        {:disabled, total}

      ["mul(" <> _bin | nums], {:enabled, total} ->
        product =
          nums
          |> Enum.map(&String.to_integer/1)
          |> Enum.product()

        {:enabled, total + product}

      ["mul(" <> _bin | _nums], {:disabled, total} ->
        {:disabled, total}
    end)
    |> elem(1)
  end
end

System.argv()
|> MullItOver.solve()
|> IO.inspect()
