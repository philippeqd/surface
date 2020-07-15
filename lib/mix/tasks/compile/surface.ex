defmodule Mix.Tasks.Compile.Surface do
  use Mix.Task
  @recursive true

  @moduledoc """
  Generates a `components.css` file with all static styles of
  all components.
  """

  @doc false
  def run(_args) do
    case generate_css() do
      "" -> {:noop, []}
      _ -> {:ok, []}
    end
  end

  defp generate_css() do
    css_file = Path.join([File.cwd!(), "priv/static/css/components.css"])

    css_content =
      Mix.Phoenix.modules()
      |> modules_with_static_style()
      |> Enum.sort()
      |> Enum.map_join("\n\n", & &1.__style__())

    header = """
    /* This file was generated by the Surface compiler */

    """

    File.write!(css_file, header <> css_content)
  end

  defp modules_with_static_style(modules) do
    Enum.filter(modules, fn mod ->
      Code.ensure_loaded?(mod) and function_exported?(mod, :__style__, 0) and
        mod.__style__() != nil
    end)
  end
end
