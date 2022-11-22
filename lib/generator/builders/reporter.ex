defmodule Generator.Builders.Reporter do
  alias Generator.FileBuilder
  alias Generator.Sites.Site
  alias Generator.Paths
  alias Generator.FileBuilder

  def write(%Site{module: module, id: site_id}) do
    module
    |> Paths.counter_folder_path()
    |> File.mkdir()

    module
    |> Paths.counter_web_folder_path()
    |> File.mkdir()

    write_cache_file(module)
    write_counter_plug_file(module)
    write_reporter(module, site_id)
    write_scheduler(module)
    # add_children_to_application_tree()
    # add_plug_to_router()
  end

  def write_scheduler(module) do
    module
    |> Paths.scheduler_file_path()
    |> File.write(FileBuilder.scheduler_file(module))
  end

  def write_reporter(module, site_id) do
    module
    |> Paths.reporter_file_path()
    |> File.write(FileBuilder.reporter_file(site_id))
  end

  def write_cache_file(module) do
    module
    |> Paths.cache_file_path()
    |> File.write(FileBuilder.cache_file(module))
  end

  def write_counter_plug_file(module) do
    module
    |> Paths.counter_plug_file_path()
    |> File.write(FileBuilder.counter_plug_file())
  end
end
