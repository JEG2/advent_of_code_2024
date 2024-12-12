defmodule PrintQueue do
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
    |> separate_jobs()
    |> elem(0)
    |> sum_middles()
  end

  def solve_part_2(input_path) do
    {_correct, incorrect, rules} = separate_jobs(input_path)

    incorrect
    |> Enum.map(fn job ->
      graph = :digraph.new()

      Enum.each(job, fn page -> :digraph.add_vertex(graph, page) end)

      Enum.each(job, fn page ->
        rules
        |> Map.get(page, MapSet.new())
        |> Enum.each(fn follow ->
          :digraph.add_edge(graph, page, follow)
        end)
      end)

      result = :digraph_utils.topsort(graph)
      :digraph.delete(graph)
      result
    end)
    |> sum_middles()
  end

  def separate_jobs(input_path) do
    {rules, jobs} =
      input_path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({%{}, []}, fn line, {rules, jobs} = acc ->
        cond do
          line == "" ->
            acc

          String.contains?(line, "|") ->
            [page, follows] =
              line
              |> String.split("|", parts: 2)
              |> Enum.map(&String.to_integer/1)

            {
              Map.update(
                rules,
                page,
                MapSet.new([follows]),
                &MapSet.put(&1, follows)
              ),
              jobs
            }

          String.contains?(line, ",") ->
            job =
              line
              |> String.split(",")
              |> Enum.map(&String.to_integer/1)

            {rules, [job | jobs]}
        end
      end)

    {correct, incorrect} =
      Enum.split_with(jobs, fn [first | rest] ->
        rest
        |> Enum.reduce_while(MapSet.new([first]), fn page, previous ->
          follows = Map.get(rules, page, MapSet.new())

          if MapSet.intersection(previous, follows) == MapSet.new() do
            {:cont, MapSet.put(previous, page)}
          else
            {:halt, false}
          end
        end)
        |> is_struct(MapSet)
      end)

    {correct, incorrect, rules}
  end

  def sum_middles(jobs) do
    jobs
    |> Enum.map(fn jobs -> Enum.at(jobs, jobs |> length() |> div(2)) end)
    |> Enum.sum()
  end
end

System.argv()
|> PrintQueue.solve()
|> IO.inspect()
