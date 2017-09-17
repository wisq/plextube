defmodule Mix.Tasks.Plex.Token do
  use Mix.Task

  @shortdoc "Get a Plex application token"

  def run([username, password]) do
    {:ok, _started} = Application.ensure_all_started(:plextube)

    headers = Plextube.Plex.headers(false)
    body = URI.encode_query(%{
      "user[login]" => username,
      "user[password]" => password,
    })

    token =
      HTTPoison.post!("https://plex.tv/users/sign_in.json", body,
        [{"Content-Type", "application/x-www-form-urlencoded"} | headers])
      |> Map.fetch!(:body)
      |> Poison.decode!
      |> Map.fetch!("user")
      |> Map.fetch!("authentication_token")

    IO.puts "Authentication successful!  Your token: #{inspect(token)}"
    IO.puts ""
    IO.puts "Put this token in your config/pipedrive.exs:"
    IO.puts ""
    IO.puts "  config :plextube,"
    IO.puts "    plex_token: #{inspect(token)}"
    IO.puts ""
  end

  def run(_) do
    Mix.raise "Usage: mix plex.token <Plex username> <Plex password>"
  end
end
