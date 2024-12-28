defmodule HoofIt do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    map = parse_input(input_path)

    map
    |> Enum.filter(fn {_xy, height} -> height == 0 end)
    |> Enum.map(fn {xy, _height} -> xy end)
    |> Enum.map(fn head ->
      1..9//1
      |> Enum.reduce([head], fn step, acc ->
        acc
        |> Enum.flat_map(fn xy -> filter_adjacent(map, xy, step) end)
        |> MapSet.new()
      end)
      |> MapSet.size()
    end)
    |> Enum.sum()
  end

  def solve_part_2(input_path) do
    map = parse_input(input_path)

    map
    |> Enum.filter(fn {_xy, height} -> height == 0 end)
    |> Enum.map(fn {xy, _height} -> xy end)
    |> Enum.map(fn head ->
      1..9//1
      |> Enum.reduce([head], fn step, acc ->
        Enum.flat_map(acc, fn xy -> filter_adjacent(map, xy, step) end)
      end)
      |> length
    end)
    |> Enum.sum()
  end

  defp parse_input(input_path) do
    input_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {height, x}, acc ->
        Map.put(acc, {x, y}, String.to_integer(height))
      end)
    end)
  end

  defp filter_adjacent(map, {x, y}, height) do
    [
      {x, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x, y + 1}
    ]
    |> Enum.map(fn xy -> {xy, Map.get(map, xy)} end)
    |> Enum.filter(fn {_xy, h} -> h == height end)
    |> Enum.map(fn {xy, _h} -> xy end)
  end
end

System.argv()
|> HoofIt.solve()
|> IO.inspect()
