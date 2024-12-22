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
    input_path
    |> parse_input()
    |> stream_moves()
    |> Enum.into(MapSet.new(), fn {xy, _direction} -> xy end)
    |> MapSet.size()
  end

  def solve_part_2(input_path) do
    state = parse_input(input_path)

    state
    |> stream_moves()
    |> Stream.transform(MapSet.new(), fn {xy, direction}, obstructions ->
      obstruction_xy = move(xy, direction)

      obstructions =
        if Map.has_key?(state.map, obstruction_xy) and
             Map.fetch!(state.map, obstruction_xy) != "#" and
             loop?(%{
               state
               | map: Map.put(state.map, obstruction_xy, "#")
             }) do
          MapSet.put(obstructions, obstruction_xy)
        else
          obstructions
        end

      {[obstructions], obstructions}
    end)
    |> Enum.at(-1)
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
    %{map: map, max_x: max_x, max_y: max_y, start: start, direction: :up}
  end

  defp stream_moves(state) do
    %{
      map: map,
      max_x: max_x,
      max_y: max_y,
      start: start,
      direction: direction
    } = state

    Stream.concat(
      [{start, direction}],
      Stream.unfold({start, direction}, fn
        {{_x, 0}, :up} ->
          nil

        {{^max_x, _y}, :right} ->
          nil

        {{_x, ^max_y}, :down} ->
          nil

        {{0, _y}, :left} ->
          nil

        {xy, direction} ->
          next_xy = move(xy, direction)

          result =
            if Map.fetch!(map, next_xy) == "#" do
              {xy, turn(direction)}
            else
              {next_xy, direction}
            end

          {result, result}
      end)
    )
  end

  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}

  defp turn(:up), do: :right
  defp turn(:right), do: :down
  defp turn(:down), do: :left
  defp turn(:left), do: :up

  defp loop?(state) do
    state
    |> stream_moves()
    |> Stream.transform(MapSet.new(), fn xy_direction, visited ->
      loop? = MapSet.member?(visited, xy_direction)
      {[loop?], MapSet.put(visited, xy_direction)}
    end)
    |> Enum.any?()
  end
end

System.argv()
|> GuardGallivant.solve()
|> IO.inspect()
