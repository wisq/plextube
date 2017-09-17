# PlexTube

PlexTube is designed to run on your Plex server.  When asked, it will download videos from YouTube and loads them into Plex.

It's designed to be easily integrated into iOS using the "Workflow" app.

## Why?

YouTube's iOS app is garbage.  It eschews the standard way to play videos in iOS, which means you lose a bunch of handy features like background playing, and (on iPad) picture-in-picture.  It doesn't buffer very much, and it *certainly* doesn't allow downloading for offline viewing.

Presumably, they do all this to allow them to show you ads, both before and in the middle of videos.  Presumably, they continue to do this even if you subscribe to YouTube Red, their ad-free service.  Not that I would know, because it's not even available in my country.

Other apps like Jonas Gessner's amazing ProTube attempted to remedy this.  But rather than take those improvements into their own app — or negotiate with these app developers to find a way to add ads, or even just limit use of third-party apps to Red subscribers — they elected to just shut down third party YouTube clients via legal threats.

PlexTube is my way of continuing to avoid using the YouTube iOS app.  It's not the most convenient way to watch YouTube, and my motivations may be petty as heck, and they may come for PlexTube next — but damned if I'm going to use their shitty app.

## Dependencies

In order to download videos, you'll need [`youtube-dl`](https://rg3.github.io/youtube-dl/).  PlexTube is pretty useless without it.

## Installation

1. Ensure dependencies are installed; see above.
2. Run `mix plex.token <your plex username> <your plex password>` to authenticate with Plex and get a token.
3. Edit `config/config.example.exs`, add your Plex token and library path, and save it as `config/config.exs`.  
4. (TODO)
