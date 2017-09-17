defmodule Plextube.PlexTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Plextube.Plex
  alias Plextube.Plex

  setup_all do
    Application.put_env(:plextube, :plex_token, "token from config")
  end

  test "headers include important fields" do
    head = Plex.headers |> Map.new

    assert String.length(head["X-Plex-Client-Identifier"]) > 0
    assert String.length(head["X-Plex-Product"]) > 0
    assert String.length(head["X-Plex-Version"]) > 0
    assert head["X-Plex-Token"] == "token from config"
  end

  test "can retrieve list of sections" do
    use_cassette "plex_sections" do
      sections = Plex.sections
      assert Enum.count(sections) == 8
      assert Enum.at(sections, 3)["uuid"] == "6e500e13-114e-4af1-8416-a7adc02531a9"
      assert List.last(sections)["title"] == "YouTube"
    end
  end

  test "can find the section for a path" do
    use_cassette "plex_sections" do
      assert Plex.section_for_path("/disk/1/plex/youtube/path/file.ext" )["title"] == "YouTube"
      assert Plex.section_for_path("/disk/1/plex/shows/file.ext"        )["title"] == "TV Shows"
      assert Plex.section_for_path("/disk/3/plex/shows/path/to/file.ext")["title"] == "TV Shows"

      assert Plex.section_for_path("/not/disk/1/plex/shows/file.ext") == nil
      assert Plex.section_for_path("/disk/1/file.ext") == nil
      assert Plex.section_for_path("/nonexistent") == nil
      assert Plex.section_for_path("/") == nil
      assert Plex.section_for_path("") == nil
    end
  end

  test "can scan a section" do
    use_cassette "refresh" do
      assert Plex.scan_section("13") == :ok
    end
  end
end
