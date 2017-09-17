defmodule Plextube.DownloadTest do
  use ExUnit.Case

  doctest Plextube.Download
  alias Plextube.Download

  defp set_ytdl(name) do
    Application.put_env(:plextube, :ytdl_wrapper, "fixture/ytdl/#{name}.sh")
    # Since we're replacing the wrapper, the "path" argument can be (ab)used
    # to give it a place to dump its args.
  end

  test "should run youtube-dl to download videos" do
    {:ok, tmpfile} = Briefly.create
    set_ytdl("rickroll")
    Download.youtube_dl("rickroll", tmpfile)

    assert {:ok, args_data} = File.read(tmpfile)

    args = args_data
           |> String.trim
           |> String.split("\n")

    assert List.first(args) == tmpfile
    assert List.last(args) == "https://www.youtube.com/watch?v=rickroll"
    assert Enum.any?(args, fn s -> String.contains?(s, " [%(id)s].") end)
  end

  test "should return a state with output file on completion (rickroll)" do
    set_ytdl("rickroll")
    assert state = Download.youtube_dl("rickroll", "/dev/null")

    assert state.state == :done
    assert state.video_percent == 100.0
    assert state.audio_percent == 100.0
    assert state.output_file == "Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].mkv"
  end

  @hey "HEYYEYAAEYAAAEYAEYAA"

  test "should return a state with output file on completion (#{@hey})" do
    set_ytdl(@hey)
    assert state = Download.youtube_dl(@hey, "/dev/null")

    assert state.state == :done
    assert state.video_percent == 100.0
    assert state.audio_percent == 100.0
    assert state.output_file == "#{@hey} [ZZ5LpwO-An4].mkv"
  end

  test "should report state if given a pid" do
    set_ytdl("rickroll")
    {all_states, final_state} = with_collector(fn collector ->
      Download.youtube_dl("rickroll", "/dev/null", collector)
    end)
    
    assert final_state.state == :done
    assert Enum.count(all_states) >= 50
    assert List.last(all_states) == final_state
  end

  test "should report percentage completion events" do
    set_ytdl("rickroll")
    {states, _} = with_collector(fn collector ->
      Download.youtube_dl("rickroll", "/dev/null", collector)
    end)

    video_percents = states
                     |> Enum.map(fn s -> s.video_percent end)
                     |> Enum.uniq
    assert Enum.count(video_percents) >= 20
    assert List.first(video_percents) ==   0.0
    assert List.last(video_percents)  == 100.0

    audio_percents = states
                     |> Enum.map(fn s -> s.audio_percent end)
                     |> Enum.uniq
    assert Enum.count(audio_percents) >= 8
    assert List.first(audio_percents) ==   0.0
    assert List.last(audio_percents)  == 100.0
  end

  defp with_collector(fun) do
    collector = spawn_link(&collect/0)

    result = fun.(collector)

    send(collector, {:done, self()})
    receive do
      {:collected, states} -> {states |> Enum.reverse, result}
    after
      1000 -> raise "timeout"
    end
  end

  defp collect(states \\ []) do
    receive do
      {:state, state} -> collect([state | states])
      {:done, pid} -> send(pid, {:collected, states})
    after
      1000 -> raise "timeout"
    end
  end
end
