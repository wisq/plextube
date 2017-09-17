defmodule Plextube.Download do
  alias Porcelain.Process, as: Proc
  alias Plextube.Download, as: Download

  @youtube_args [
    "--ignore-config",
    "-f", "bestvideo+bestaudio",
    "-o", "%(title)s [%(id)s].%(ext)s",
  ]

  defstruct [
    report_pid: nil,
    state: :pending,
    video_percent: 0.0,
    audio_percent: 0.0,
    output_file: nil,
  ]

  def youtube_dl(url, report_pid \\ nil) do
    opts = [out: :stream]
    args = @youtube_args ++ [url]
    %Proc{out: outstream} = Porcelain.spawn("youtube-dl", args, opts)

    initial_state = %Download{report_pid: report_pid}

    outstream
    |> Enum.reduce(initial_state, &process_ytdl_output/2)
    |> check_output_file
    |> Map.put(:state, :done)
    |> report_state
  end

  defp check_output_file(%Download{output_file: nil}), do:
    raise "youtube-dl completed but did not mention an output file"
  defp check_output_file(state), do: state

  defp process_ytdl_output(output, old_state) do
    new_state =
      [
        {&out_youtube/1,  ~r/\[youtube\] [^\s:]+: Downloading /},
        {&out_dl_start/1, ~r/\[download\] Destination: /},
        {&out_percent/2,  ~r/\[download\]\s+(\d+(?:\.\d+)?)% of \d/},
        {&out_merging/2,  ~r/\[ffmpeg\] Merging formats into "([^\n]+)"\n/},
      ]
      |> Enum.reduce(old_state, fn(rx, state) -> check_output_regex(rx, output, state) end)

    new_state
    |> report_state
  end

  defp check_output_regex({fun, regex}, output, state) do
    Regex.scan(regex, output)
    |> Enum.reduce(state, fn([_ | matches], state) ->
      apply(fun, [state | matches])
    end)
  end

  defp out_youtube(state) do
    state |> Map.put(:state, :get_metadata)
  end

  defp out_dl_start(%{state: :get_metadata} = state) do
    state |> Map.put(:state, :download_video)
  end
  defp out_dl_start(%{state: :download_video} = state) do
    state |> Map.put(:state, :download_audio)
  end

  defp out_percent(state, "100"), do: out_percent(state, "100.0")
  defp out_percent(%{state: :download_video} = state, percent) do
    state |> Map.put(:video_percent, String.to_float(percent))
  end
  defp out_percent(%{state: :download_audio} = state, percent) do
    state |> Map.put(:audio_percent, String.to_float(percent))
  end

  defp out_merging(state, file) do
    state
    |> Map.put(:output_file, file)
    |> Map.put(:state, :merging)
  end

  defp report_state(%Download{report_pid: nil} = state), do: state
  defp report_state(%Download{report_pid: pid} = state) do
    send(pid, {:state, state})
    state
  end
end
