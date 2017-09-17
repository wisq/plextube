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

  setup do
    {:ok, library} = Briefly.create(directory: true)
    Application.put_env(:plextube, :secret, nil)
    Application.put_env(:plextube, :library_path, library)
    Plextube.DownloadTest.set_ytdl("rickroll")
  end

  test "POST to /call retrieves video synchronously" do
    mock_plex = [
      section_for_path: fn p ->
        assert File.dir?(p)
        assert p |> String.contains?("briefly")
        %{"key" => "123"}
      end,
      scan_section: fn "123" -> :ok end,
    ]

    conn = conn(:post, "/call", url: "https://youtube.com/watch?v=rickroll")
    conn = with_mock Plextube.Plex, mock_plex do
      Web.call(conn, @opts)
    end

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"content-type" => "application/json"} = conn.resp_headers |> Map.new

    body = conn.resp_body |> Poison.decode!
    assert body["success"] == true
    assert body["video_id"] == "rickroll"
    assert body["file"] == "Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].mkv"
  end

  test "POST to /cast retrieves video asynchronously" do
    me = self()
    mock_plex = [
      section_for_path: fn p ->
        assert File.dir?(p)
        assert p |> String.contains?("briefly")
        %{"key" => "321"}
      end,
      scan_section: fn "321" ->
        send(me, :scanned)
        :ok
      end,
    ]

    conn = conn(:post, "/cast", url: "https://youtube.com/watch?v=rickroll")
    with_mock Plextube.Plex, mock_plex do
      conn = Web.call(conn, @opts)

      assert conn.state == :sent
      refute_received(:scanned) # hopefully it's not so fast that it fails this
      assert conn.status == 200
      assert %{"content-type" => "application/json"} = conn.resp_headers |> Map.new

      body = conn.resp_body |> Poison.decode!
      assert body["success"] == true
      assert body["video_id"] == "rickroll"
      assert body["file"] == nil

      assert_receive(:scanned)
    end
  end

  test "/call rejects incorrect secret" do
    secret = 'secret must be sent' |> Enum.shuffle |> List.to_string
    Application.put_env(:plextube, :secret, secret)

    mock_plex = [
      section_for_path: fn _ -> %{"key" => "123"} end,
      scan_section: fn "123" -> :ok end,
    ]

    with_mock Plextube.Plex, mock_plex do
      conn = conn(:post, "/call", url: "https://youtube.com/watch?v=rickroll")
      conn = Web.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 403
      refute called Plextube.Plex.scan_section("123")
    end

    with_mock Plextube.Plex, mock_plex do
      conn = conn(:post, "/call", url: "https://youtube.com/watch?v=rickroll", secret: secret)
      conn = Web.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert called Plextube.Plex.scan_section("123")
    end
  end

  test "/cast rejects incorrect secret" do
    secret = 'secret must be sent' |> Enum.shuffle |> List.to_string
    Application.put_env(:plextube, :secret, secret)

    me = self()
    mock_plex = [
      section_for_path: fn _ -> %{"key" => "123"} end,
      scan_section: fn "123" -> send(me, :scanned) end,
    ]

    with_mock Plextube.Plex, mock_plex do
      conn = conn(:post, "/cast", url: "https://youtube.com/watch?v=rickroll")
      conn = Web.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 403
      refute_receive(:scanned)
      refute called Plextube.Plex.scan_section("123")
    end

    with_mock Plextube.Plex, mock_plex do
      conn = conn(:post, "/cast", url: "https://youtube.com/watch?v=rickroll", secret: secret)
      conn = Web.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert_receive(:scanned)
      assert called Plextube.Plex.scan_section("123")
    end
  end
end
