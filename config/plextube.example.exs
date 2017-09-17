use Mix.Config

# To configure Plex, run
#
#   mix plex.token <your Plex username> <your Plex password>
#
# and replace YOUR-TOKEN with the token it gives you.

config :plextube,
  plex_token: "YOUR-TOKEN",
  library_path: "/path/to/write/videos/to"

# By default, we listen on 127.0.0.1 (localhost) port 3232.
# Change to 0.0.0.0 if you want it public.
#
#  bind_to_ip:   "127.0.0.1",
#  bind_to_port: 3232
#

# PlexTube needs to know how to reach your Plex server to request a media scan.
# The default should work if your Plex server is local.  If not, change this.
# (Note that the path is ignored; we just use the scheme + host + port.)
#
#  plex_uri: "http://127.0.0.1:32400/"
#

# If you're going to make your PlexTube public, you should probably
# consider setting `secret` to a string.  All requests must supply
# an identical `secret` parameter.
#
#  secret: nil
#

# Plextube writes videos to a temporary directory before moving them to library_path.
# It's recommended that this directory be on the same disk as library_path,
# so that moving files is fast and atomic.
#
# If your library_path is on the same disk as /tmp, you're fine.
# If not, you can either set your TMPDIR environment variable, or edit the path below.
#
#config :briefly,
#  directory: ["/path/to/temporary/directory"]

