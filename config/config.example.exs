use Mix.Config

# To configure Plex, run
#
#   mix plex.token <your Plex username> <your Plex password>
#
# and replace YOUR-TOKEN with the token it gives you.

config :plextube,
  plex_token: "YOUR-TOKEN"
  library_path: "/path/to/write/videos/to"

# Other options and their defaults:
#
#  bind_to_ip:   "127.0.0.1"  # IP address for web listener
#  bind_to_port: 3232         # port for web listener
#
#  plex_uri: "http://127.0.0.1:32400/"  # URL to access your Plex server
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
