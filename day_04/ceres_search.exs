defmodule CeresSearch do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    grid = read_grid(input_path)

    grid
    |> Stream.filter(fn {_xy, letter} -> letter == "X" end)
    |> Stream.map(&elem(&1, 0))
    |> Enum.reduce(0, fn {x, y}, acc ->
      acc +
        Enum.count(
          [{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}],
          fn {x_offset, y_offset} ->
            ~w{M A S}
            |> Enum.with_index(1)
            |> Enum.all?(fn {expected, i} ->
              grid[{x + x_offset * i, y + y_offset * i}] == expected
            end)
          end
        )
    end)
  end

  def solve_part_2(input_path) do
    grid = read_grid(input_path)

    grid
    |> Stream.filter(fn {_xy, letter} -> letter == "A" end)
    |> Stream.map(&elem(&1, 0))
    |> Enum.reduce(0, fn {x, y}, acc ->
      if ((grid[{x - 1, y - 1}] == "M" and grid[{x + 1, y + 1}] == "S") or
            (grid[{x - 1, y - 1}] == "S" and grid[{x + 1, y + 1}] == "M")) and
           ((grid[{x - 1, y + 1}] == "M" and grid[{x + 1, y - 1}] == "S") or
              (grid[{x - 1, y + 1}] == "S" and grid[{x + 1, y - 1}] == "M")) do
        acc + 1
      else
        acc
      end
    end)
  end

  defp read_grid(input_path) do
    input_path
    |> File.stream!()
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> String.trim()
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.reduce(acc, fn {letter, x}, acc ->
        Map.put(acc, {x, y}, letter)
      end)
    end)
  end
end

System.argv()
|> CeresSearch.solve()
|> IO.inspect()
