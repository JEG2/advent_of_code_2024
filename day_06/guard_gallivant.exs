defmodule GuardGallivant do
  def solve(args) do
    case OptionParser.parse!(args, strict: [part_2: :boolean]) do
      {[part_2: true], [input_path]} ->
        solve_part_2(input_path)

      {_part_1, [input_path]} ->
        solve_part_1(input_path)
    end
  end

  def solve_part_1(input_path) do
    %{map: map, start: start, max_x: max_x, max_y: max_y} =
      parse_input(input_path)

    {start, :up, MapSet.new([start])}
    |> Stream.iterate(fn {xy, direction, visited} ->
      next_xy = move(xy, direction)

      if Map.fetch!(map, next_xy) == "#" do
        {xy, turn(direction), visited}
      else
        {next_xy, direction, MapSet.put(visited, next_xy)}
      end
    end)
    |> Enum.find(fn
      {{_x, 0}, :up, _visited} -> true
      {{^max_x, _y}, :right, _visited} -> true
      {{_x, ^max_y}, :down, _visited} -> true
      {{0, _y}, :left, _visited} -> true
      _not_on_edge -> false
    end)
    |> elem(2)
    |> MapSet.size()
  end

  def solve_part_2(input_path) do
    %{map: map, start: start, max_x: max_x, max_y: max_y} =
      parse_input(input_path)

    {start, :up, MapSet.new(), MapSet.new()}
    |> Stream.iterate(fn {xy, direction, corners, obstructions} ->
      next_xy = move(xy, direction)

      if Map.fetch!(map, next_xy) == "#" do
        {xy, turn(direction), MapSet.put(corners, xy), obstructions}
      else
        if loop?(xy, direction, corners, map) do
          {
            next_xy,
            direction,
            corners,
            MapSet.put(obstructions, next_xy)
          }
        else
          {next_xy, direction, corners, obstructions}
        end
      end
    end)
    |> Enum.find(fn
      {{_x, 0}, :up, _previous, _obstructions} -> true
      {{^max_x, _y}, :right, _previous, _obstructions} -> true
      {{_x, ^max_y}, :down, _previous, _obstructions} -> true
      {{0, _y}, :left, _previous, _obstructions} -> true
      _not_on_edge -> false
    end)
    |> elem(3)
    |> MapSet.size()
  end

  defp parse_input(input_path) do
    map =
      input_path
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {location, x}, acc ->
          Map.put(acc, {x, y}, location)
        end)
      end)

    {start, "^"} = Enum.find(map, fn {_xy, location} -> location == "^" end)
    max_x = map |> Map.keys() |> Enum.map(fn {x, _y} -> x end) |> Enum.max()
    max_y = map |> Map.keys() |> Enum.map(fn {_x, y} -> y end) |> Enum.max()
    %{map: map, start: start, max_x: max_x, max_y: max_y}
  end

  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}

  defp turn(:up), do: :right
  defp turn(:right), do: :down
  defp turn(:down), do: :left
  defp turn(:left), do: :up

  defp loop?({x, y}, :up, corners, map) do
    Enum.any?(corners, fn {corner_x, corner_y} ->
      Map.get(map, {x - 1, y}) != "#" and corner_y == y and corner_x > x and
        Enum.all?((x + 1)..corner_x, fn mx ->
          Map.fetch!(map, {mx, y}) != "#"
        end)
    end)
  end

  defp loop?({x, y}, :right, corners, map) do
    Enum.any?(corners, fn {corner_x, corner_y} ->
      Map.get(map, {x, y - 1}) != "#" and corner_x == x and corner_y > y and
        Enum.all?((y + 1)..corner_y, fn my ->
          Map.fetch!(map, {x, my}) != "#"
        end)
    end)
  end

  defp loop?({x, y}, :down, corners, map) do
    Enum.any?(corners, fn {corner_x, corner_y} ->
      Map.get(map, {x + 1, y}) != "#" and corner_y == y and corner_x < x and
        Enum.all?((x - 1)..corner_x//-1, fn mx ->
          Map.fetch!(map, {mx, y}) != "#"
        end)
    end)
  end

  defp loop?({x, y}, :left, corners, map) do
    Enum.any?(corners, fn {corner_x, corner_y} ->
      Map.get(map, {x, y + 1}) != "#" and corner_x == x and corner_y < y and
        Enum.all?((y - 1)..corner_y//-1, fn my ->
          Map.fetch!(map, {x, my}) != "#"
        end)
    end)
  end

  defp loop?(_xy, _direction, _corners, _map), do: false
end

System.argv()
|> GuardGallivant.solve()
|> IO.inspect()
