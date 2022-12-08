defmodule LinkHelper do
  @active "bg-gray-100 text-gray-900 group rounded-md py-2 px-2 flex items-center text-sm font-medium"

  def active_link(conn, group, base_class \\ "") do
    if group in conn.path_info do
      @active <> base_class
    else
      base_class
    end
  end
end
