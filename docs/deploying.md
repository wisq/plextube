# Deploying

## Local setup

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

## Server setup

Once deployed, you'll want to start it.  There's generally two ways to do this.  From within the `~plextube/app/plextube` directory (or whatever user/path you've deployed to):

* `bin/plextube start` will start PlexTube as a daemon (in the background).  You can automate this with init scripts, `cron`, etc.  (It's harmless to run if the server is already up.)
* `bin/plextube foreground` will start PlexTube in the current session, not in the background.  This isn't very useful if you're running it from the command line, but it's great for tools like `runit`.

If you're using a modern Linux distribution, chances are you're using `systemd` (for better or worse).  In that case, you probably want to see [the Distillery instructions for systemd](https://github.com/bitwalker/distillery/blob/master/docs/Use%20With%20systemd.md), which allow you to use either of the two above methods.

## wtf?

If you're familiar with Distillery, you may be wondering what the heck I'm doing with these `rsync` commands.  Yes, I'm aware that the "proper" way to deploy is to let Distillery build a `.tar.gz` file (i.e. `mix release` without the `--no-tar`), copy that tarball to the deploy target, and let the target unpack it.

However, that requires bumping the version every deploy, which is a bit of a pain.  Plus, it tends to work best with a dedciated build/CI host and a repository of release files, which I consider **massive** overkill for a hobby project like this.
