defmodule Plextube.Plex do
  @otp_version :erlang.system_info(:otp_release) |> List.to_string

  # Used externally by `mix plextube.token`
  def headers(with_token \\ true)
  def headers(true),  do: [{"X-Plex-Token", plex_token()} | headers(false)]
  def headers(false), do: [
    {"X-Plex-Client-Identifier", "plextube-48ef629c-c1ce-448f-9767-283d5b04a32e"},
    {"X-Plex-Device-Name", "PlexTube"},
    {"X-Plex-Product", "plextube"},
    {"X-Plex-Version", Plextube.version},
    {"X-Plex-Platform", "Erlang"},
    {"X-Plex-Platform-Version", @otp_version},
    {"Accept", "application/json"},
  ]

  def sections do
    get!("/library/sections")
    |> Map.fetch!("MediaContainer")
    |> Map.fetch!("Directory")
  end

  def section_for_path(path) do
    sections()
    |> Enum.find(&section_contains_path?(&1, path))
  end

  def scan_section(key) do
    get!("/library/sections/#{key}/refresh")
  end


  defp plex_token do
    token = Application.get_env(:plextube, :plex_token)
    if is_nil(token) || token == "YOUR-TOKEN", do: raise "Must set :plex_token in config/plextube.exs"
    token
  end

  defp plex_uri do
    Application.get_env(:plextube, :plex_uri, "http://127.0.0.1:32400/")
    |> URI.parse
  end

  defp get!(path) do
    plex_uri()
    |> Map.put(:path, path)
    |> HTTPoison.get!(headers())
    |> decode_body
  end

  def decode_body(%{body: ""}), do: :ok
  def decode_body(%{body: body}), do: body |> Poison.decode!

  defp section_contains_path?(section, path) do
    section
    |> Map.fetch!("Location")
    |> Enum.any?(fn %{"path" => p} -> path_contains?(p, path) end)
  end

  defp path_contains?(parent, child) do
    split_parent = Path.split(parent)
    split_child  = Path.split(child)
    List.starts_with?(split_child, split_parent)
  end
end
