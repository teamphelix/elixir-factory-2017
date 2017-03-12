defmodule Mix.Tasks.Digest do
  use Mix.Task

  def run(_) do
    Mix.Shell.IO.cmd "NODE_ENV=production ../../../assets/webpack -p"
  end
end