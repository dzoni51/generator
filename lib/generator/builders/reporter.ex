defmodule Generator.Builders.Reporter do
  alias Generator.Sites.Site
  alias Generator.Paths
  alias Generator.Builders.FileBuilder

  @spec write(Site.t()) :: :ok
  def write(%Site{module: module}) do
    module
    |> Paths.counter_folder_path()
    |> File.mkdir()

    module
    |> Paths.counter_web_folder_path()
    |> File.mkdir()

    write_cache_file(module)
    write_counter_plug_file(module)

    :ok
  end

  @spec write_cache_file(String.t()) :: :ok | {:error, any()}
  def write_cache_file(module) do
    module
    |> Paths.cache_file_path()
    |> File.write(FileBuilder.cache_file(module))
  end

  @spec write_counter_plug_file(String.t()) :: :ok | {:error, any()}
  def write_counter_plug_file(module) do
    module
    |> Paths.counter_plug_file_path()
    |> File.write(FileBuilder.counter_plug_file())
  end
end
