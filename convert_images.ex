defmodule Mix.Tasks.ConvertImages4 do
  use Mix.Task

  @default_glob "./image_uploads/*"
  @default_target_dir "./tmp"
  @default_format "jpg"

  # NOTE: we could also have refactored this using `with`, but
  #       it doesn't really matter for the point I'm trying to make ^_^

  def run(argv) do
    argv
    |> parse_options()
    |> validate_options()
    |> prepare_conversion()
    |> convert_images()
    |> report_results()
  end

  defp parse_options(argv) do
    {opts, args, _invalid} =
      OptionParser.parse(argv, switches: [target_dir: :string, format: :string])

    glob = List.first(args) || @default_glob
    target_dir = opts[:target_dir] || @default_target_dir
    format = opts[:format] || @default_format

    {glob, target_dir, format}
  end

  defp validate_options({glob, target_dir, format}) do
    filenames = Path.wildcard(glob)

    if Enum.empty?(filenames) do
      raise "No images found."
    end

    unless Enum.member?(~w[jpg png], format) do
      raise "Unrecognized format: #{format}"
    end

    {glob, target_dir, format}
  end

  defp prepare_conversion({glob, target_dir, format}) do
    File.mkdir_p!(target_dir)

    filenames = Path.wildcard(glob)

    {filenames, target_dir, format}
  end

  defp convert_images({filenames, target_dir, format}) do
    results =
      Enum.map(filenames, fn filename ->
        Converter.convert_image(filename, target_dir, format)
      end)

    {results, target_dir}
  end

  defp report_results({results, target_dir}) do
    IO.puts("Wrote #{Enum.count(results)} images to #{target_dir}.")
  end
end
