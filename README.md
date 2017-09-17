# PlexTube

PlexTube is designed to run on your Plex server.  When asked, it will download videos from YouTube and loads them into Plex.

It's designed to be easily integrated into iOS using the "Workflow" app.

## Why?

YouTube's iOS app is garbage.  It eschews the standard way to play videos in iOS, which means you lose a bunch of handy features like background playing, and (on iPad) picture-in-picture.  It doesn't buffer very much, and it *certainly* doesn't allow downloading for offline viewing.

Presumably, they do all this to allow them to show you ads, both before and in the middle of videos.  Presumably, they continue to do this even if you subscribe to YouTube Red, their ad-free service.  Not that I would know, because it's not even available in my country.

Other apps like Jonas Gessner's amazing ProTube attempted to remedy this.  But rather than take those improvements into their own app — or negotiate with these app developers to find a way to add ads, or even just limit use of third-party apps to Red subscribers — they elected to just shut down third party YouTube clients via legal threats.

PlexTube is my way of continuing to avoid using the YouTube iOS app.  It's not the most convenient way to watch YouTube, and my motivations may be petty as heck, and they may come for PlexTube next — but damned if I'm going to use their shitty app.

## Dependencies

### Erlang and Elixir

PlexTube is written in Elixir, which is a language running on top of Erlang.  You'll need both of these to make it work.

If you follow the [Elixir install instructions](https://elixir-lang.org/install.html), you should end up with both of these.  Most of the automatic (i.e. packaged) installs will automatically install Erlang for you.  The manual install methods include instructions on installing Erlang.

If you're installing the Debian/Ubuntu packages, make sure to include `erlang-dev` (the Erlang headers) and `erlang-tools` (some development tools).  These are needed by PlexTube's dependencies.

PlexTube was written in Elixir 1.5 running on Erlang 20.  You can try running it under older versions, but there's no guarantees it'll work.

### `youtube-dl`

In order to download videos, you'll need [`youtube-dl`](https://rg3.github.io/youtube-dl/).  PlexTube is pretty useless without it.

Make sure it's somewhere in your `$PATH`.  If you choose to deploy as another user, make sure it's in *their* `$PATH`.  (You may also want to make it writable by that user so you can schedule a `youtube-dl --update` now and then.)

### ffmpeg

PlexTube will tell `youtube-dl` to download the best video and audio quality that YouTube has available.  These generally involve fetching two different formats, and then combining the video from one with the audio from the other.

Merging these two formats together requires an encoder like `ffmpeg`.  If you edit the source and change the `youtube-dl` arguments, you can get away without it … but who doesn't want the best quality results?

### YouTube agent for Plex

You'll almost certainly want the [YouTube metadata agent for Plex](https://forums.plex.tv/discussion/83106/rel-youtube-metadata-agent).  It'll fill in the proper title, author, and description for each video.

To install, you'll need to rename the extracted directory to `YouTube-Agent.bundle` and put it into your Plex server's plugin directory.  See [these instructions](https://support.plex.tv/hc/en-us/articles/201187656-How-do-I-manually-install-a-channel-) for details.

Be sure to enable it in your server preferences — it's under Server → Agents → Films → YouTube — and set your library type to the "Films" with the "YouTube" agent selected.  You'll also probably want to enable the "Set YouTube usernames as director in metadata" feature.

## Installation

### Installing

1. Ensure dependencies are installed; see above.
2. Run `mix deps.get` to fetch the libraries PlexTube needs.
3. Run `mix plex.token <your plex username> <your plex password>` to authenticate with Plex and get a token.
4. Edit `config/plextube.example.exs`, add your Plex token and library path, and save it as `config/plextube.exs`.

Now, you have two options on how to run PlexTube

### Running on the spot

For beginners, I recommend just running `mix plextube.server`.  This will launch the server right here and now, ready to accept requests.  (To exit the server, press control-C twice.)

By default, it listens on localhost (`127.0.0.1`), port 3232.  If you want to open this up to the world, you'll need to edit your `config/plextube.exs` and set `bind_to_ip` to `0.0.0.0`.  (You may also have to set up port forwarding so the world can reach you.)

This should be enough to get you going.  However, if you're an experienced Elixir developer and/or sysadmin, and you want more flexibility, you can try deploying instead.

### Deploying

Deploying PlexTube (via Distillery) offers a few extra benefits:

* You can run it as a different user, and/or on a different host.
* You can do running restarts, without restarting the Erlang VM.
* The target host need not have Elixir or Erlang installed.
  * … as long as the host you're building has the same OS, architecture, and library versions.

To get these benefits, however, you'll need to do some extra steps.

First, we need a few more files:

* `config/prod.exs`: Your production config.  If you want the same config in your local development and deployed versions, then just copy `dev.exs` to `prod.exs`.  Otherwise, copy `plextube.exs` and edit the config as needed.
* `rel/config.exs`: Your release config.  Copy this from `rel/config.example.exs` and edit as needed (see below).
  * If `include_erts` is `true`, then (in theory) the deploy is self-contained and doesn't need Erlang/Elixir.  However, you'll need very similar OS, architecture, and library versions to make this work.
* (optional) `Makefile`: Makes deploying easier.  Copy `Makefile.example`, (optionally) rename one of the `deploy_*` targets to just `deploy`, and delete the rest.

Now, either run `make deploy` (if you did all of the above), or check the `Makefile.example` to see how you might do a deploy yourself.  (Since this is your first deploy, it's normal to see the "not responding to pings" error — you haven't started it yet.)

Once deployed, you'll want to start it.  There's generally two ways to do this.  From within the `~plextube/app/plextube` directory (or whatever user/path you've deployed to):

* `bin/plextube start` will start PlexTube as a daemon (in the background).  You can automate this with init scripts, `cron`, etc.  (It's harmless to run if the server is already up.)
* `bin/plextube foreground` will start PlexTube in the current session, not in the background.  This isn't very useful if you're running it from the command line, but it's great for tools like `runit`.

If you're using a modern Linux distribution, chances are you're using `systemd` (for better or worse).  In that case, you probably want to see [the Distillery instructions for systemd](https://github.com/bitwalker/distillery/blob/master/docs/Use%20With%20systemd.md), which allow you to use either of the two above methods.

*(Note that the "proper" way to deploy is to let Distillery build a `.tar.gz` file (i.e. `mix release` without the `--no-tar`), copy that tarball to the deploy target, and let the target unpack it.  However, that requires bumping the version every deploy, which is a bit of a pain.  Plus, it tends to work best with a dedciated build/CI host and a repository of release files, which I consider **massive** overkill for a hobby project like this.)*

## OH GOD WHAT

If all of the above is way too complicated for you, then consider installing [YouTubeTV](https://github.com/kolsys/YouTubeTV.bundle) instead.  Instead of downloading videos, it adds a YouTube channel to your Plex server.

(Heck, you should install it either way — I use YouTubeTV for my subscriptions, and PlexTube for other videos.)

Once installed, you can sign in as your YouTube account, view your subscriptions / history / etc., and enjoy all the benefits of Plex (except offline viewing).  However, I believe only the server owner can use this — so while other users won't see your history etc., you also can't easily share videos with them.
