defmodule Plextube.WebTest do
  use ExUnit.Case
  use Plug.Test
  import Mock

  doctest Plextube.Web
  alias Plextube.Web

  @opts Web.init([])

  setup_all do
    Application.put_env(:plextube, :plex_token, "token from config")
  end

  test "POST to /call retrieves video synchronously" do
    {:ok, library} = Briefly.create(directory: true)
    Application.put_env(:plextube, :library_path, library)
    Plextube.DownloadTest.set_ytdl("rickroll")

    mock_plex = [
      section_for_path: fn p ->
        assert File.dir?(p)
        assert p |> String.contains?("briefly")
        %{"key" => "123"}
      end,
      scan_section: fn "123" -> :ok end,
    ]

    # Create a test connection
    conn = conn(:post, "/call", url: "https://youtube.com/watch?v=rickroll")

    # Invoke the plug
    conn = with_mock Plextube.Plex, mock_plex do
      Web.call(conn, @opts)
    end

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert %{"content-type" => "application/json"} = conn.resp_headers |> Map.new

    body = conn.resp_body |> Poison.decode!
    assert body["success"] == true
    assert body["video_id"] == "rickroll"
    assert body["file"] == "Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].mkv"
  end
end
