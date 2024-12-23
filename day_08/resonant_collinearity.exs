defmodule ResonantCollinearity do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    find_antinodes(input_path, fn {{x1, y1}, {x2, y2}}, _max_x, _max_y ->
      {dx, dy} = {x2 - x1, y2 - y1}
      [{x1 - dx, y1 - dy}, {x2 + dx, y2 + dy}]
    end)
  end

  def solve_part_2(input_path) do
    find_antinodes(input_path, fn {{x1, y1}, {x2, y2}}, max_x, max_y ->
      {dx, dy} = {x2 - x1, y2 - y1}

      Stream.concat(
        {x1, y1}
        |> Stream.iterate(fn {x, y} -> {x - dx, y - dy} end)
        |> Enum.take_while(fn {x, y} ->
          x >= 0 and x <= max_x and y >= 0 and y <= max_y
        end),
        {x2, y2}
        |> Stream.iterate(fn {x, y} -> {x + dx, y + dy} end)
        |> Enum.take_while(fn {x, y} ->
          x >= 0 and x <= max_x and y >= 0 and y <= max_y
        end)
      )
    end)
  end

  def find_antinodes(input_path, f) do
    {antennas, max_x, max_y} =
      input_path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.with_index()
      |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, max_x, max_y} ->
        map =
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reject(fn {location, _x} -> location == "." end)
          |> Enum.reduce(map, fn {antenna, x}, map ->
            Map.update(map, antenna, [{x, y}], &[{x, y} | &1])
          end)

        {map, max(max_x, String.length(line) - 1), max(max_y, y)}
      end)

    antennas
    |> Stream.flat_map(fn {_id, xys} ->
      xys
      |> Enum.with_index()
      |> Enum.flat_map(fn {xy, i} ->
        xys
        |> Enum.drop(i + 1)
        |> Enum.map(fn other -> {xy, other} end)
      end)
    end)
    |> Stream.flat_map(&f.(&1, max_x, max_y))
    |> Stream.filter(fn {x, y} ->
      x >= 0 and x <= max_x and y >= 0 and y <= max_y
    end)
    |> MapSet.new()
    |> MapSet.size()
  end
end

System.argv()
|> ResonantCollinearity.solve()
|> IO.inspect()
