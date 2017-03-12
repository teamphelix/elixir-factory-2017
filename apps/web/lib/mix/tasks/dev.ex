defmodule Mix.Tasks.Dev do
  use Mix.Task

  @doc "Run and dev with webpack"
  def run(_) do
    Mix.Shell.IO.cmd "cd assets && npm start"
  end
end