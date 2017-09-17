defmodule Mix.Tasks.Plextube.Server do
  use Mix.Task

  @shortdoc "Launch the PlexTube server"

  def run([ip, port]) do
    Application.put_env(:plextube, :bind_to_ip, ip)
    run([port])
  end
  def run([port]) do
    Application.put_env(:plextube, :bind_to_port, port |> String.to_integer)
    run([])
  end
  def run([]) do
    Mix.Tasks.Run.run(["--no-halt"])
  end

  def run(_) do
    Mix.raise """
    Usage:

      mix plextube.server
      mix plextube.server <port>
      mix plextube.server <bind to IP> <port>
    """
  end
end
