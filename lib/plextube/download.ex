defmodule Plextube.Download do
  require Logger
  alias Porcelain.Process, as: Proc
  alias Plextube.Download, as: Download

  @youtube_args [
    "--ignore-config",
    "-f", "bestvideo+bestaudio",
    "-o", "%(title)s [%(id)s].%(ext)s",
  ]

  defstruct [
    video_id: nil,
    report_pid: nil,
    state: :pending,
    video_percent: 0.0,
    audio_percent: 0.0,
    output_file: nil,
  ]

  defp wrapper_path do
    Application.get_env(:plextube, :ytdl_wrapper,
      Application.app_dir(:plextube, "priv/youtube-dl.sh"))
  end

  def video_url(v_id), do: "https://www.youtube.com/watch?v=#{v_id}"

  def youtube_dl(v_id, path, report_pid \\ nil) do
    opts = [out: :stream]
    args = @youtube_args ++ [video_url(v_id)]
    %Proc{out: outstream} = Porcelain.spawn(wrapper_path(), [path | args], opts)

    initial_state = %Download{
      video_id: v_id,
      report_pid: report_pid,
    }

    outstream
    |> Enum.reduce(initial_state, &process_ytdl_output/2)
    |> check_output_file
    |> Map.put(:state, :done)
    |> report_state
  end

  defp check_output_file(%Download{output_file: nil}), do:
    raise "youtube-dl completed but did not mention an output file"
  defp check_output_file(state) do
    state
    |> log("Downloaded #{inspect(state.output_file)}.")
  end

  defp process_ytdl_output(output, old_state) do
    new_state =
      [
        {&out_youtube/2,  ~r/\[youtube\] [^\s:]+: Downloading ([^\n]+)\n/},
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

  defp out_youtube(state, what) do
    state
    |> log("Getting #{what} ...")
    |> Map.put(:state, :get_metadata)
  end

  defp out_dl_start(%{state: :get_metadata} = state) do
    state
    |> log("Downloading video ...")
    |> Map.put(:state, :download_video)
  end
  defp out_dl_start(%{state: :download_video} = state) do
    state
    |> log("Downloading audio ...")
    |> Map.put(:state, :download_audio)
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
    |> log("Merging ...")
    |> Map.put(:output_file, file)
    |> Map.put(:state, :merging)
  end

  defp report_state(%Download{report_pid: nil} = state), do: state
  defp report_state(%Download{report_pid: pid} = state) do
    send(pid, {:state, state})
    state
  end

  defp log(state, message) do
    Logger.info("Video #{state.video_id}: #{message}")
    state
  end
end
