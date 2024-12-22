defmodule BridgeRepair do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    combine_terms(input_path, fn l, r -> [l + r, l * r] end)
  end

  def solve_part_2(input_path) do
    combine_terms(input_path, fn l, r ->
      [l + r, l * r, String.to_integer("#{l}#{r}")]
    end)
  end

  defp combine_terms(input_path, f) do
    input_path
    |> File.stream!()
    |> Stream.map(fn line ->
      Regex.scan(~r{\d+}, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Stream.filter(fn [goal, start | terms] ->
      {totals, []} =
        {[start], terms}
        |> Stream.iterate(fn {totals, [t | rest]} ->
          {Enum.flat_map(totals, &f.(&1, t)), rest}
        end)
        |> Enum.find(fn {_total, rest} -> rest == [] end)

      goal in totals
    end)
    |> Stream.map(&hd/1)
    |> Enum.sum()
  end
end

System.argv()
|> BridgeRepair.solve()
|> IO.inspect()
