defmodule DiskFragmenter do
  require Integer

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
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce({%{}, nil, 0}, fn
      {0, _i}, acc ->
        acc

      {len, i}, {blocks, free, cursor} when Integer.is_even(i) ->
        {
          Enum.into(0..(len - 1), blocks, fn offset ->
            {cursor + offset, div(i, 2)}
          end),
          free,
          cursor + len
        }

      {len, i}, {blocks, free, cursor} when Integer.is_odd(i) ->
        {blocks, free || cursor, cursor + len}
    end)
    |> then(fn {blocks, free, cursor} -> {blocks, free, cursor - 1} end)
    |> Stream.iterate(fn {blocks, free, cursor} ->
      {
        blocks
        |> Map.put_new(free, Map.fetch!(blocks, cursor))
        |> Map.delete(cursor),
        Enum.find((free + 1)..cursor//1, &(not Map.has_key?(blocks, &1))),
        reduce_cursor(blocks, cursor)
      }
    end)
    |> Enum.find(fn {_blocks, free, cursor} -> free >= cursor end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.reduce(0, fn {i, id}, acc -> acc + i * id end)
  end

  def solve_part_2(input_path) do
    input_path
    |> File.read!()
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce({%{}, [], 0}, fn
      {0, _i}, acc ->
        acc

      {len, i}, {blocks, free, cursor} when Integer.is_even(i) ->
        {Map.put(blocks, cursor, {div(i, 2), len}), free, cursor + len}

      {len, i}, {blocks, free, cursor} when Integer.is_odd(i) ->
        {blocks, [{cursor, len} | free], cursor + len}
    end)
    |> then(fn {blocks, free, cursor} ->
      {blocks, Enum.reverse(free), reduce_cursor(blocks, cursor)}
    end)
    |> Stream.iterate(fn {blocks, free, cursor} ->
      {id, len} = Map.fetch!(blocks, cursor)

      {blocks, free} =
        case Enum.find_index(free, fn {i, l} -> i < cursor and len <= l end) do
          j when is_integer(j) ->
            {i, l} = Enum.at(free, j)

            blocks =
              blocks
              |> Map.put_new(i, {id, len})
              |> Map.delete(cursor)

            free =
              if len == l do
                List.delete_at(free, j)
              else
                List.replace_at(free, j, {i + len, l - len})
              end

            {blocks, free}

          nil ->
            {blocks, free}
        end

      {blocks, free, reduce_cursor(blocks, cursor)}
    end)
    |> Enum.find(fn {_blocks, _free, cursor} -> is_nil(cursor) end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.reduce(0, fn {i, {id, len}}, acc ->
      Enum.reduce(0..(len - 1), acc, fn offset, acc ->
        acc + (i + offset) * id
      end)
    end)
  end

  defp reduce_cursor(blocks, cursor) do
    Enum.find((cursor - 1)..0//-1, &Map.has_key?(blocks, &1))
  end
end

System.argv()
|> DiskFragmenter.solve()
|> IO.inspect()
