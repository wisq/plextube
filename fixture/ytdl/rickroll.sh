#!/bin/sh

. fixture/ytdl/dump_args.sh

# Captured in IEx using
#
#   alias Porcelain.Process, as: Proc
#   %Proc{out: outstream} = Porcelain.spawn("youtube-dl", ["--ignore-config", "-f", "bestvideo+bestaudio", "-o", "%(title)s [%(id)s].%(ext)s", "https://www.youtube.com/watch?v=dQw4w9WgXcQ"], in: "bogus", out: :stream); lines = outstream |> Enum.to_list
#   File.write!("target", lines |> Enum.map(&inspect/1) |> Enum.join("\n"))
#
# and then editing the result.
#
# It's important not to use the built-in echo here, because we need each
# echo to be sent as a separate entry on the stream, and builtins tend
# to gum everything together.
#
# That's not critically broken, but it's not correct either.

/bin/echo -e -n "[youtube] dQw4w9WgXcQ: Downloading webpage\n"
/bin/echo -e -n "[youtube] dQw4w9WgXcQ: Downloading video info webpage\n"
/bin/echo -e -n "[youtube] dQw4w9WgXcQ: Extracting video information\n"
/bin/echo -e -n "[youtube] dQw4w9WgXcQ: Downloading js player vflUnLBiU\n"
/bin/echo -e -n "[youtube] dQw4w9WgXcQ: Downloading MPD manifest\n"
/bin/echo -e -n "[download] Destination: Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].f137.mp4\n"
/bin/echo -e -n "\r\e[K[download]   0.0% of 82.40MiB at Unknown speed ETA Unknown ETA"
/bin/echo -e -n "\r\e[K[download]   0.0% of 82.40MiB at  2.61MiB/s ETA 00:32"
/bin/echo -e -n "\r\e[K[download]   0.0% of 82.40MiB at  5.26MiB/s ETA 00:15"
/bin/echo -e -n "\r\e[K[download]   0.0% of 82.40MiB at 10.42MiB/s ETA 00:07"
/bin/echo -e -n "\r\e[K[download]   0.0% of 82.40MiB at  2.94MiB/s ETA 00:28"
/bin/echo -e -n "\r\e[K[download]   0.1% of 82.40MiB at  2.55MiB/s ETA 00:32"
/bin/echo -e -n "\r\e[K[download]   0.2% of 82.40MiB at  3.00MiB/s ETA 00:27"
/bin/echo -e -n "\r\e[K[download]   0.3% of 82.40MiB at  4.08MiB/s ETA 00:20"
/bin/echo -e -n "\r\e[K[download]   0.6% of 82.40MiB at  6.62MiB/s ETA 00:12"
/bin/echo -e -n "\r\e[K[download]   1.2% of 82.40MiB at 10.63MiB/s ETA 00:07"
/bin/echo -e -n "\r\e[K[download]   2.4% of 82.40MiB at 16.42MiB/s ETA 00:04"
/bin/echo -e -n "\r\e[K[download]   4.9% of 82.40MiB at 24.92MiB/s ETA 00:03"
/bin/echo -e -n "\r\e[K[download]   9.7% of 82.40MiB at 36.77MiB/s ETA 00:02"
/bin/echo -e -n "\r\e[K[download]  14.6% of 82.40MiB at 41.78MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  19.4% of 82.40MiB at 38.50MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  24.3% of 82.40MiB at 43.10MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  29.1% of 82.40MiB at 42.04MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  34.0% of 82.40MiB at 45.19MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  38.8% of 82.40MiB at 47.13MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]  43.7% of 82.40MiB at 48.48MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  48.5% of 82.40MiB at 50.03MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  53.4% of 82.40MiB at 48.48MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  58.3% of 82.40MiB at 48.88MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  63.1% of 82.40MiB at 49.22MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  68.0% of 82.40MiB at 48.90MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  72.8% of 82.40MiB at 49.00MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  77.7% of 82.40MiB at 48.93MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  82.5% of 82.40MiB at 48.72MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  87.4% of 82.40MiB at 48.59MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  92.2% of 82.40MiB at 48.20MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  97.1% of 82.40MiB at 47.42MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download] 100.0% of 82.40MiB at 46.98MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download] 100% of 82.40MiB in 00:01\n"
/bin/echo -e -n "[download] Destination: Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].f251.webm\n"
/bin/echo -e -n "\r\e[K[download]   0.0% of 3.33MiB at Unknown speed ETA Unknown ETA"
/bin/echo -e -n "\r\e[K[download]   0.1% of 3.33MiB at  2.84MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]   0.2% of 3.33MiB at  5.02MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]   0.4% of 3.33MiB at  9.06MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]   0.9% of 3.33MiB at  2.76MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]   1.8% of 3.33MiB at  2.49MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]   3.7% of 3.33MiB at  3.18MiB/s ETA 00:01"
/bin/echo -e -n "\r\e[K[download]   7.5% of 3.33MiB at  4.59MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  15.0% of 3.33MiB at  7.48MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  30.0% of 3.33MiB at 10.93MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download]  60.0% of 3.33MiB at 17.42MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download] 100.0% of 3.33MiB at 24.11MiB/s ETA 00:00"
/bin/echo -e -n "\r\e[K[download] 100% of 3.33MiB in 00:00\n"
/bin/echo -e -n "[ffmpeg] Merging formats into \"Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].mkv\"\n"
/bin/echo -e -n "Deleting original file Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].f137.mp4 (pass -k to keep)\n"
/bin/echo -e -n "Deleting original file Rick Astley - Never Gonna Give You Up [dQw4w9WgXcQ].f251.webm (pass -k to keep)\n"
