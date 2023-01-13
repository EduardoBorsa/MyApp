defmodule MyApp.Helpers.Util do
  def date_for_input(timestamp) do
    case Timex.format(timestamp, "{YYYY}-{0M}-{0D}") do
      {:ok, formatted} -> formatted
      {:error, _} -> timestamp
    end
  end

  def date_from_input(timestamp) do
    case Timex.parse(timestamp, "{YYYY}-{0M}-{0D}") do
      {:ok, due_date} ->
        due_date

      {:error, _} ->
        nil
    end
  end

  def display_date(timestamp) do
    case Timex.format(timestamp, "{Mfull} {D}, {YYYY}") do
      {:ok, formatted} -> formatted
      {:error, _} -> timestamp
    end
  end

  def display_date_time(timestamp) do
    case Timex.format(timestamp, "{Mfull} {D}, {YYYY} - {h12}:{0m} {AM}") do
      {:ok, formatted} -> formatted
      {:error, _} -> timestamp
    end
  end

  def current_date_in_period(start_date, end_date) do
    current_date = Date.utc_today()

    (Date.compare(start_date, current_date) == :lt ||
       Date.compare(start_date, current_date) == :eq) &&
      (Date.compare(end_date, current_date) == :gt || Date.compare(end_date, current_date) == :eq)
  end

  def current_date_is_after(limit_date) do
    current_date = Date.utc_today()
    Date.compare(current_date, limit_date) == :gt
  end

  def current_date_is_prior(limit_date) do
    current_date = Date.utc_today()
    Date.compare(current_date, limit_date) == :lt
  end

  def current_date_is_prior_or_equal(limit_date) do
    current_date = Date.utc_today()
    Date.compare(current_date, limit_date) == :lt || Date.compare(current_date, limit_date) == :eq
  end

  def valid_file_size(file) do
    %{size: size} = File.stat!(file.path)
    size <= 50 * 1000 * 1000
  end

  def convert_snake_case_to_space(payload) do
    String.replace(payload, "_", " ")
  end

  def changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {_k, v}, _acc ->
      joined_errors = Enum.join(v, "; ")
      "#{joined_errors}\n"
    end)
  end

  def is_path(conn, resource, index) do
    Enum.find_index(conn.path_info, fn x -> x == resource end) == index
  end

  def name_from_struct(struct) do
    struct.__struct__
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
  end

  def normalize_map(%Date{} = arg), do: arg
  def normalize_map(%NaiveDateTime{} = arg), do: arg

  def normalize_map(%{__struct__: _} = model) do
    model
    # Since models are implemented Jason protocols and phoenix and ecto are declaring Poison use
    # deprecated in views and models, use Jason to normalize instead
    |> Jason.encode!()
    |> Jason.decode!()
    |> normalize_map()
  end

  def normalize_map(arg) when is_map(arg) do
    Enum.reduce(arg, %{}, fn {k, val}, result ->
      Map.put(result, if(is_atom(k), do: k, else: String.to_atom(k)), normalize_item(val))
    end)
  end

  def from_iso8601_to_utc_datetime!(iso_date_time) do
    iso_date_time
    |> Date.from_iso8601!()
    |> Date.to_iso8601()
    |> Kernel.<>(" 00:00:00Z")
    |> DateTime.from_iso8601()
    |> Kernel.elem(1)
  end

  defp normalize_item(%DateTime{} = arg), do: arg
  defp normalize_item(arg) when is_map(arg), do: normalize_map(arg)
  defp normalize_item(arg) when is_list(arg), do: Enum.map(arg, &normalize_item(&1))
  defp normalize_item(arg), do: arg

  def generate_color_from_name(firstname, lastname) do
    "#" <>
      (:crypto.hash(:sha256, "#{firstname} #{lastname}")
       |> Base.encode16()
       |> String.downcase()
       |> String.slice(0..5))
  end

  def generate_random_chars(n) do
    :crypto.strong_rand_bytes(n)
    |> Base.url_encode64(padding: false)
    |> Kernel.<>(" - ")
  end

  def struct_to_map(structure) when is_map(structure) do
    atom_map =
      structure
      |> Map.from_struct()

    atom_map
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, map ->
      Map.put(map, Atom.to_string(key), Map.fetch!(atom_map, key))
    end)
  end
end
